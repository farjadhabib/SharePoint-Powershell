function Modify-SPFolderPermissionsByUrl {
	param (
        [Parameter(Mandatory=$true)]
        [string] $SPUrl, #Site Collection URL
		[Parameter(Mandatory=$true)]
        [string] $SPFolderUrl, #folder relative url to the site collection or List/Library name in case of whole list/library
        [Parameter(Mandatory=$true)]
        [string] $SPGroup, #Group to give permission
        [Parameter(Mandatory=$false)]
        [string] $SPGroupDesc, #Group to give permission
        [Parameter(Mandatory=$true)]
        [string] $PermissionLevel #permissions level
    )

    #add the reference to sharepoint powershell
    Add-PSSnapin Microsoft.SharePoint.Powershell

    #get sharepoint site collecction
    $site = Get-SPSite $SPUrl
    $web = $site.OpenWeb()

    #add the group to site if not already added
    if($null -eq $web.SiteGroups[$SPGroup]){
        $web.SiteGroups.Add($SPGroup,$user, $user,$SPGroupDesc)
        $web.Update()
    }
    $group = $web.SiteGroups[$SPGroup]

    #create role with given permission level
    $role = $web.RoleDefinitions[$PermissionLevel]

    #get folder for the permissions to change
    $folder = web.GetFolder($SPUrl+"/"+$SPFolderUrl)
    $item = $folder.Item;

    #break inheritance if not unique
    if($item.HasUniqueRoleAssignments -ne $true){
        $item.BreakRoleInheritance($false)
        $item.Update()
    }

    #remove all inherited role assignments
    $roleAssignments = $item.RoleAssignments
    for ($i=$roleAssignments.count-1; $i –gt 0; $i--)
    {
        $roleAssignments.Remove(0)
    }
    $item.Update()

    #assign permissions to the group
    $roleassignment = New-Object Microsoft.SharePoint.SPRoleAssignment($group)
    $roleassignment.RoleDefinitionBindings.Add($role)
    $roleAssignments.Add($roleassignment)
    $item.Update()

}

#example call
Modify-SPFolderPermissionsByUrl -SPUrl "<sharepoint site collection url>" -SPFolderUrl "<folder url relative to site collection>" -SPGroup "<group to assign permissions to>" -SPGroupDesc "<group description in case new group to be added>" -PermissionLevel "<permissions level for te group>" -Verbose
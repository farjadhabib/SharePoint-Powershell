function Modify-SharePointIndexLocation {
	param (
        [Parameter(Mandatory=$true)]
        [string] $SSAName, #Search Service Application Name
		[Parameter(Mandatory=$true)]
        [string] $newIndexLocation #new index location, absolute path
    )
    #get the search service instance
    $ssi = Get-SPEnterpriseSearchServiceInstance
    $ssi.Components

    #get search service application by name
    $ssa = Get-SPEnterpriseSearchServiceApplication $SSAName

    #get the local search service instance
    $instance=Get-SPEnterpriseSearchServiceInstance -Local

    #get search service topology
    $current=Get-SPEnterpriseSearchTopology -SearchApplication $ssa

    #create a clone of current topology
    $clone=New-SPEnterpriseSearchTopology -Clone -SearchApplication $ssa -SearchTopology $current

    #create search index component for the cloned topology
    New-SPEnterpriseSearchIndexComponent -SearchTopology $clone -IndexPartition 0 -SearchServiceInstance $instance -RootDirectory $newIndexLocation

    #set the cloned topology
    Set-SPEnterpriseSearchTopology -Identity $clone

    #remove the current topology
    Remove-SPEnterpriseSearchTopology -Identity $current

}

#example call
Modify-SharePointIndexLocation -SSAName "<Search Service App Name>" -newIndexLocation "<Absolute Path>" -Verbose
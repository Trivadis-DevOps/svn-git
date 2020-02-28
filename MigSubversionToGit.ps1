#
# MigSubversionToGit.ps1
# --------------------------

# Init variable

# SVN Repo Name 
[string]$SVNRepoName = "" 

# SVN Repo Server URL 
[string]$SVNServerURL = "" 

# Local Migration Folder 
[string]$LocalMigrationFolder = "" 
 
# SVN Repo Local Folder 
[string]$SVNLocalFolder = $LocalMigrationFolder + "SVN\"

# GIT Repo Local Folder 
[string]$GitLocalFolder = $LocalMigrationFolder + "GIT\"

# GIT Repo URL 
[string]$GitRepoURL = ""

# GIT Repo Name 
[string]$GITRepoName = ""

# For svn transport authentication (please read more at: https://git-scm.com/docs/git-svn)
[string]$username = ""

# 1. Created Local Folders 

mkdir $($SVNLocalFolder + $SVNRepoName)
mkdir $($GitLocalFolder + $GITRepoName)

# 2. Get direct online from SVN over TortoiseSVN and then run this for create authors mapping file 

cd $SVNLocalFolder
$env:PATH += ';C:\Program Files\TortoiseSVN\bin'

cd $($SVNLocalFolder + $SVNRepoName)
svn.exe log $($SVNServerURL + $SVNRepoName) --quiet | ? { $_ -notlike '-*' } | % { ($_ -split ' \| ')[1] + ' = firstname lastname <firstname.lastname@domain.com>' } | Sort -Unique | Out-File -Encoding ascii  AuthorsMapping.txt

# 2.1 edit authors mapping file and add the user with email ex. user = Firstname Lastname <firstname.lastname@domain.com> 

Write-Host 'Please edit the Authors Mapping File and then press any key to continue...';
$null = [System.Console]::ReadKey().Key.ToString();

# 3. Clone Azure DevOps GIT Repo to local Folder 

cd $($GitLocalFolder)
# warning is ok because empty repository
git clone $GitRepoURL

# 4. Initialise the link between Git and SVN (--stdlayout uses the standard /trunk, /branches, and /tags directory layout)   

cd $($GitLocalFolder + $GITRepoName)

git svn init --stdlayout --username $username

# 5. Fetch from SVN with the authors mapping file (can run over hours)

git svn fetch -A $($SVNLocalFolder + $SVNRepoName + "\AuthorsMapping.txt")

# 6. convert branch and tags 
# show all references

git for-each-ref --format='%(refname)' refs/remotes/origin/tags --sort='creatordate'

# 6.1 for tags

git for-each-ref --format='%(refname)' refs/remotes/origin/tags | % {
    #Extract the 5th field from every line 
    $_.Split("/")[4]
} | % {
    #Foreach value extracted in the previous loop 
    & git tag $_ "refs/remotes/origin/tags/$_"
}

# show all created tags
git tag -l

# 6.2 for branch 

git for-each-ref --format='%(refname)' refs/remotes/origin | % {
    #Extract the 4th field from every line 
    $_.Split("/")[3]
	# exclude branches because already exist (master) or not valid
	} | % { if ($_ -ne 'trunk' -And $_ -ne 'tags' -And $_ -ne 'HEAD' -And $_ -ne 'master' )
	#} | % { if ($_ -ne 'trunk' )
			{
				#Foreach value extracted in the previous loop 
				& git branch $_ "refs/remotes/origin/$_"
			}
	}

	
# show all created branches
git branch -l

# 6.2.1 when in svn branches not in branches folder then need to update config file in .git\config 
# under section [svn-remote "svn"] add this for ex. branches = branch_*:refs/remotes/origin/* 

# 7. push to GIT: (when hang can try push over visual studio connect local Git Repo with Add then Sync and then push) 
# 7.1 push all branches inc. master 
# git config core.autocrlf false
# git config core.autocrlf

git remote add upstream $GitRepoURL

git push upstream --all --progress

# 7.1 push all tags 

git push upstream --tags

Write-Host 'Finished';
$null = [System.Console]::ReadKey().Key.ToString();
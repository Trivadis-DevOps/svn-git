#Introduction
svn-git is a power shell tool which migrates all branches and tags including all history from Subversion to Git.

#Use svn-git

Open the MigSubversionToGit.ps1 and read the steps and comments to get familiar with the workflow. 

Edit the variables section. Fill out following variables:

* $SVNRepoName 
* $SVNServerURL
* $LocalMigrationFolder
* $GitRepoURL
* $GITRepoName
* $username

##Manual Steps
Here are all steps you will need to do:

1. Init variables.
2. Edit authors mapping file (you will find the mapping file located under your migration folder with subroot svn).
3. Wait till the script finishes and check your Git repository. 

# Help

Do not hesitate to ask questions or open Issues. 
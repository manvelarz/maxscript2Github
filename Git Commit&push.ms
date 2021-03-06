﻿macroScript Git_Add_Commit_PUSH
	category:"Manvel"
	toolTip:"Add commit and push to github"
	ButtonText:"GitPush"
(

Global IniPath = (getDir #temp + "\\Git_info.ini")
Global Git_repo_Path = GetINISetting IniPath "LastGitFolder" "Path"
Global Git_Remote_repo_Path = GetINISetting IniPath "LastGitFolder" "RemPath"
Global RepoFolderName = GetINISetting IniPath "LastGitFolder" "Folder"
try(closeRolloutFloater rof) catch()
Global rof=newrolloutfloater "Git" 280 400 500 500
Global message = ""	

	
	
fn Git_folder = (
	thePath = getSavepath initialDir:(maxfilepath)
	if thePath != undefined then (
		gitFolderExist = false
		for d in getDirectories (thePath+"\\*") do (
			a = filterString d "\\"
			if  a[a.count] == ".git" then (
				gitFolderExist = true
				RepoFolderName = a[a.count-1]
				print RepoFolderName
				)
				else gitFolderExist = false
		)
		if gitFolderExist then (
			Git_Remote_repo_Path
			setINISetting IniPath "LastGitFolder" "Path" thePath
			setINISetting IniPath "LastGitFolder" "Folder" RepoFolderName
			repoConfigINIFile = thePath+"/.git/config"
			setINISetting IniPath "LastGitFolder" "RemPath" (GetINISetting repoConfigINIFile "remote \"origin\"" "url")
			format "actual git folder is %" thePath
			Git_repo_Path = thePath
			Git_Remote_repo_Path = getINISetting IniPath "LastGitFolder" "RemPath"
			
			for r in rof.rollouts where r.name == "RepoRollout" do( 
				r.open=false
				r.title = "Repo-->  " + RepoFolderName
				r.Tgfolder.text = thePath
				)
			return thePath
			) 
			else (
			messagebox "You need to select proper Git folder (Repo)\n\nThe script take a look if there are a '.git' folder\n inside of the selected folder" title:"Alert"
			return ""
			)
		
	)
)
	
	
rollout RepoRollout "Repository" width:290 height:328
	(
		group "Set/Change Git directory" (
			edittext Tgfolder RepoFolderName  text:Git_repo_Path  readOnly:true labelOnTop:true--enabled:true -- align:#left
			button 'Select_Git_Folder' "Select Git Folder(Repo)" pos:[16,88] width:232 height:24 align:#left
			on Select_Git_Folder pressed do 
				Git_folder()
		)	
	)
	rollout addFiles "Add files" width:290 height:328
	(
		group "Add all files in folder to repo" (
			--edittext Tgfolder RepoFolderName  text:Git_repo_Path  readOnly:true labelOnTop:true--enabled:true -- align:#left
			button BtnaddFiles "Add all"  width:232 height:24 align:#center
			on BtnaddFiles pressed do 
				ShellLaunch "cmd"  ("/k cd "+Git_repo_Path +"  && git add ." )
		)	
	)
rollout CommitAndPushRollout "Commit local repository" width:290 height:328
	(
		group "Enter a message for commit" (
			edittext tMessage "" pos:[16,24] width:232  height:56 readOnly:false align:#left -- text:ultimo_Mananger_Access_ip   
			button btnCommit "Commit with message" pos:[16,88] width:232 height:23 enabled:false align:#left
			on tMessage  changed text do(
				message = text
				btnCommit.enabled = on
				)
			on btnCommit pressed do
			(		
				if message == "" then message= "message generated from Maxscript"
				
				ShellLaunch "cmd"  ("/k cd "+Git_repo_Path +" && git commit -a -m \""+message+"" )
				)
		)

		button 'Gitpush' "Push to github"  width:248 height:43 align:#center
			button 'LocalRepo' "Open Local"  align:#center
		button 'RemoteRepo' "Open Remote"  align:#center
		on RemoteRepo pressed do
			(		
				ShellLaunch Git_Remote_repo_Path ""
			)
		on LocalRepo pressed do
			(		
				ShellLaunch Git_repo_Path ""
			)
		on Gitpush pressed do
			(		
				ShellLaunch "cmd"  ("/k cd "+Git_repo_Path +"  && git push" )
			)		
		on CommitAndPush open do closerollout 
	)

	addrollout RepoRollout  rof
	addrollout addFiles rof
	
	addrollout CommitAndPushRollout   rof
	for r in rof.rollouts where r.name == "RepoRollout" do( r.open=false; r.title = "Actual repo is -->  " + RepoFolderName)
)

using terms from application "MetaZ"
	on queue completed document the_document
		tell application "MetaZ"
			set myid to content of tag "TV app persistent ID" of the_document
			set loc to file of the_document
		end tell
		if myid is not missing value then
			tell application "TV"
				set trk to missing value
				try
					set trk to first track whose persistent ID is equal to myid
				on error errMsg number errNum
					-- your error handler code goes here
				end try
				if trk is not missing value then
					set location of trk to loc
					refresh trk
				end if
			end tell
		end if
	end queue completed document
	
	on opened document the_document
		if application "TV" is running then
			tell application "MetaZ"
				set myid to content of tag "TV app persistent ID" of the_document
				set myname to content of tag "title" of the_document
				set myloc to file of the_document as alias
			end tell
			if myid is missing value then
				tell application "TV"
					set trks to every track whose name is myname
					repeat with currentTrack in trks
						if location of currentTrack is equal to myloc then
							set myid to persistent ID of currentTrack
							tell application "MetaZ"
								set content of tag "TV app persistent ID" of the_document to myid
								return
							end tell
						end if
					end repeat
				end tell
			end if
		end if
	end opened document
end using terms from

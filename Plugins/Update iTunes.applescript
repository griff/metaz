on queue_completed on the_document
	tell application "MetaZ"
		set myid to content of tag "iTunes persistent ID" of the_document
		set loc to file of the_document
	end tell
	if myid is not missing value then
		tell application "iTunes"
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
end queue_completed
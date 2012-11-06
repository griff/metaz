on queue_completed on the_document
	tell application "MetaZ"
		set myid to content of tag "iTunes persistent ID" of the_document
		set loc to file of the_document
	end tell
	-- Only add if not already in iTunes
	if myid is missing value then
		tell application "iTunes"
			add loc
		end tell
	end if
end queue_completed

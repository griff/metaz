using terms from application "MetaZ"
	on queue completed document the_document
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
	end queue completed document
end using terms from

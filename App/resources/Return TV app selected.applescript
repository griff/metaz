tell application "TV"
	set sel to selection
	set ret to {}
	set retRef to a reference to ret
	set len to length of sel
	repeat with n from 1 to len
		set obj to item n of sel
		set i to {mylocation:location of obj, myid:persistent ID of obj}
		copy i to the end of retRef
	end repeat
end tell
return ret

on queue_started()
	display dialog "Wheee Started"
end queue_started

on queue_writing on the_document
	display dialog "Wheee Writing " & (name of the_document)
end queue_writing

on queue_completed on the_document
	display dialog "Wheee Item Completed " & (name of the_document)
end queue_completed

on queue_failed on the_document
	display dialog "Wheee Item Failed " & (name of the_document)
end queue_failed

on queue_finished()
	display dialog "Wheee Finished"
end queue_finished

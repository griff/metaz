--
--	Created by: Brian Olsen
--	Created on: 11/06/12 17:45:16
--
--	Copyright (c) 2012 Maven-Group
--	All Rights Reserved
--

using terms from application "MetaZ"
	
	on queue started processing
		display dialog "Wheee Started"
	end queue started processing
	
	on queue started document the_document
		display dialog "Wheee Writing " & (name of the_document)
	end queue started document
	
	on queue completed document the_document
		display dialog "Wheee Item Completed " & (name of the_document)
	end queue completed document
	
	on queue failed to write the_document because of the_error
		display dialog "Wheee Item Failed " & (name of the_document)
	end queue failed to write
	
	on queue finished processing
		display dialog "Wheee Finished"
	end queue finished processing
	
	on opened document the_document
		display dialog "Wheee Opened " & (name of the_document)
	end opened document
	
end using terms from

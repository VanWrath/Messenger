note
	description: "Summary description for {ERROR_MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ERROR_MESSAGE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			ok
			message := ""
		end

feature -- Attributes

	status: STRING
	message: STRING
	err_state: BOOLEAN

feature -- Command errors

	ok
		do
			status := "  OK%N"
			err_state := false
		end

	ok_message
		do
			message := ""
		end

	error
		do
			status := "  ERROR %N"
			err_state := true
		end

	id_not_positive
		do
			message := "  ID must be a positive integer.%N"
			err_state := true
		end

	id_in_use
		do
			message := "  ID already in use.%N"
			err_state := true
		end

	user_start
		do
			message := "  User name must start with a letter.%N"
			err_state := true
		end

	group_start
		do
			message := "  Group name must start with a letter.%N"
			err_state := true
		end

	user_dne
		do
			message := "  User with this ID does not exist.%N"
			err_state := true
		end

	group_dne
		do
			message := "  Group with this ID does not exist.%N"
			err_state := true
		end

	reg_exists
		do
			message := "  This registration already exists.%N"
			err_state := true
		end

	msg_empty
		do
			message := "  A message may not be an empty string.%N"
			err_state := true
		end

	auth_send
		do
			message := "  User not authorized to send messages to the specified group.%N"
			err_state := true
		end

	msg_dne
		do
			message := "  Message with this ID does not exist.%N"
			err_state := true
		end

	auth_access
		do
			message := "  User not authorized to access this message.%N"
			err_state := true
		end

	already_read
		do
			message := "  Message has already been read. See `list_old_messages'.%N"
			err_state := true
		end

	del_err
		do
			message := "  Message with this ID not found in old/read messages.%N"
			err_state := true
		end

	prev_len
		do
			message := "  Message length must be greater than zero.%N"
			err_state := true
		end

feature -- Query errors

	no_groups
		do
			message := "  There are no groups registered in the system yet.%N"
			err_state := true
		end

	no_users
		do
			message := "  There are no users registered in the system yet.%N"
			err_state := true
		end
end

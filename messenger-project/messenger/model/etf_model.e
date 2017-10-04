note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create s.make_empty
			create m.make
			i := 0
			create err_msg.make
			create message.make_empty
		end

feature -- model attributes
	s : STRING
	i : INTEGER
	m : MESSENGER
	message: STRING
	err_msg : ERROR_MESSAGE
	program_started: BOOLEAN
	is_query :BOOLEAN

feature

	add_user (uid: INTEGER_64; user_name: STRING)
		do
			m.add_user (uid, user_name)
			program_started := true
		end

	add_group (gid: INTEGER_64; group_name: STRING)
		do
			m.add_group(gid, group_name)
			program_started := true
		end

	register_user (uid: INTEGER_64; gid: INTEGER_64)
		do
			m.register_user (uid, gid)
		end

	send_message (uid: INTEGER_64; gid: INTEGER_64; txt: STRING)

		do
			m.send_message (uid, gid, txt)
		end

	read_message (uid: INTEGER_64; mid: INTEGER_64)
		do
			if attached m.users.at (uid) as a_user and attached m.messages.at (mid) as a_message then
				message := "  Message for user [" + a_user.id.out + ", " + a_user.name + "]: [" + a_message.mid.out + ", %"" +  a_message.text + "%"]%N"
			end

			m.read_message (uid, mid)
		end

	delete_message (uid: INTEGER_64; mid: INTEGER_64)
		do
			m.delete_message (uid, mid)
		end

	set_message_preview (n: INTEGER_64)
		do
			m.set_message_preview (n.as_integer_32)
			program_started := true
		end

	list_new_messages (uid: INTEGER_64)
		do
			message := m.list_new_messages (uid)
			is_query := true
		end

	list_old_messages (uid: INTEGER_64)
		do
			message := m.list_old_messages (uid)
			is_query := true
		end

	list_groups
		do
			message := m.list_groups
			is_query := true
		end

	list_users
		do
			message := m.list_users
			is_query := true
		end

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1
		end

	reset
			-- Reset model state.
		do
			make
		end

feature -- queries
	out : STRING
		do
			create Result.make_from_string ("  ")
			Result.append (i.out)
			Result.append (":")
			Result.append (err_msg.status)
			Result.append (err_msg.message)
			if not err_msg.err_state then
				if program_started then
					Result.append (message)
					if not is_query then
						Result.append(m.out)
					end
				end
			end
			is_query := false
			message := ""
		end

end





note
	description: "Summary description for {MESSENGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSENGER

inherit
	ANY
		redefine out end

create {ETF_MODEL}
	make

feature
	make
		do
			create users.make(50)
			create groups.make (50)
			create messages.make(100)
			message_length := 15
			mid_count := 1
		ensure
			attached users
			attached groups
			attached messages
		end

feature --attributes
	users: HASH_TABLE[USER, INTEGER_64]
		--Table of all users in the system, with user is at the key

	groups: HASH_TABLE[GROUP, INTEGER_64]
		--Table of all groups in the system with group id as the key

	messages: HASH_TABLE[MESSAGE, INTEGER_64]
		--Table of all messages in the system with message id as the key

	message_length: INTEGER

	mid_count: INTEGER_64
		--counter used to assign message ids to new sent messages.

feature--commands

	add_user (uid: INTEGER_64; uname: STRING)
		--add user 'uid' with name 'uname' to the system
		require
			positive_id: uid > 0
			unique_id: not users.has (uid)
			alpha_name: uname.count > 0 and uname[1].is_alpha

		local
			new_user: USER
		do
			create new_user.make_with_name_and_id(uname, uid)
			users.extend (new_user, uid)

		ensure
			user_added:
				users.has (uid)
				and attached users.at (uid) as user
				and then user.name ~ uname
		end

	add_group(gid: INTEGER_64; g_name: STRING)
		--add a group 'gid' with name 'g_name' to the system
		require
			positive_id: gid > 0
			unique_id: not groups.has (gid)
			alpha_name: g_name.count > 0 and g_name[1].is_alpha

		local
			new_group: GROUP
		do
			create new_group.make_with_name_and_id(g_name, gid)
			groups.extend(new_group, gid)

		ensure
			group_added:
				groups.has (gid)
				and (attached groups.at(gid) as group)
				and then (group.name ~ g_name)
		end

	register_user (uid: INTEGER_64; gid: INTEGER_64)
		--add a user 'uid' to a group 'gid'
		require
			uid_exists: users.has (uid)
			gid_exists: groups.has (gid)
			not_in_group: not user_in_group(uid, gid)
		do
			if attached users.item (uid) as user and attached groups.at (gid) as group then
				user.add_group (group)
				group.add_user (user)
			end

		ensure
			user_registered:
				attached users.item (uid) as user
				and then attached groups.at (gid) as group
				and then user.groups.has (group)
		end

	send_message (uid: INTEGER_64; gid: INTEGER_64; text: STRING)
		--send message 'text' from user 'uid' to group 'gid'
		require
			positive_id: uid > 0 and gid > 0
			uid_exists: users.has (uid)
			gid_exists: groups.has (gid)
			not_empty_string: not text.is_empty
			user_in_group: user_in_group(uid, gid)

		local
			a_message: MESSAGE
		do
			create a_message.make (text, mid_count, gid, uid)
			messages.extend (a_message, mid_count)
			if attached groups.at(gid) as curr_group then
				from curr_group.users.start
				until curr_group.users.after
				loop
					if curr_group.users.item.id /= uid then
						curr_group.users.item.new_messages.extend (a_message, mid_count)
					else
						curr_group.users.item.old_messages.extend (a_message, mid_count)
					end
					curr_group.users.forth
				end
			end
			mid_count := mid_count + 1
		ensure
			message_sent: message_sent(uid, gid, old mid_count)
		end

	read_message (uid: INTEGER_64; mid: INTEGER_64)
		--read message 'mid' for user 'uid'
		require
			positive_id: uid > 0 and mid > 0
			uid_exists: users.has (uid)
			mid_exists: messages.has (mid)
			can_read: authorized_to_read(uid, mid)
			message_is_new: message_is_new(uid, mid)

		do
			if attached users.at (uid) as a_user then
				a_user.read_message (mid)
			end
		end

	delete_message (uid: INTEGER_64; mid: INTEGER_64)
		--delete the message 'mid' from the user 'uid'
		require
			positive_id: uid > 0 and mid > 0
			user_id_exist: users.has (uid)
			mid_exist: messages.has (mid)
			mid_is_old: has_old_msg(uid,mid)

		do
			if attached users.at (uid) as a_user then
				a_user.old_messages.remove (mid)
			end

		ensure
			message_deleted:
				attached users.at (uid) as user
				and then not (user.old_messages.has (mid))
		end

	set_message_preview	(n: INTEGER)
		--sets the length of messages during preview
		require
			nonnegative_value: n > 0
		do
			message_length := n

		ensure
			updated_message_length: message_length = n
		end

feature --queries

	 list_new_messages (uid: INTEGER_64):STRING
        --lists new messages of user 'uid'
        local
            i: INTEGER
            msg_keys: SORTED_TWO_WAY_LIST[INTEGER_64]
            temp:STRING
        do
            create Result.make_empty
            create temp.make_empty
            create msg_keys.make
            if attached users.at (uid) as user and then not user.new_messages.is_empty then
                msg_keys.fill (user.new_messages.current_keys)
                Result := "  New/unread messages for user [" + uid.out + ", " + user.name + "]:%N"

                from
                    i := 1
                until
                    i > msg_keys.count
                loop
                    if attached user.new_messages.at (msg_keys.at (i)) as msg then
                        Result.append ("      " + msg.mid.out + "->" )
                        Result.append ("[sender: " + msg.sender_id.out + ", group: " + msg.gid.out + ", content: %"")
                        if msg.text.count > message_length then
                            temp.make_from_string (msg.text)
                            temp.remove_substring (message_length.as_integer_32 + 1, temp.count)
                            result.append (temp + "...%"]%N")
                        else
                            Result.append (msg.text + "%"]%N")
                        end
                    end
                    i := i + 1
                end
            else
                Result.append ("  There are no new messages for this user.%N")
            end
        end

	list_old_messages (uid: INTEGER_64):STRING
        --lists old messages of user 'uid'
        local
            i: INTEGER
            msg_keys: SORTED_TWO_WAY_LIST[INTEGER_64]
            temp:STRING
        do
            create Result.make_empty
                    create temp.make_empty
                    create msg_keys.make
                    if attached users.at (uid) as user and then not user.old_messages.is_empty then
                        msg_keys.fill (user.old_messages.current_keys)
                        Result := "  Old/read messages for user [" + uid.out + ", " + user.name + "]:%N"

                        from
                            i := 1
                        until
                            i > msg_keys.count
                        loop
                            if attached user.old_messages.at (msg_keys.at (i)) as msg then
                                Result.append ("      " + msg.mid.out + "->" )
                                Result.append ("[sender: " + msg.sender_id.out + ", group: " + msg.gid.out + ", content: %"")
                                if msg.text.count > message_length then
                                    temp.make_from_string (msg.text)
                                    temp.remove_substring (message_length.as_integer_32 + 1, temp.count)
                                    result.append (temp + "...%"]%N")
                                else
                                    Result.append (msg.text + "%"]%N")
                                end
                            end
                            i := i + 1
                        end
                    else
                        Result.append ("  There are no old messages for this user.%N")
                    end
        end

	list_groups: STRING
		--lists all groups in the messenger system sorted alphabetically, then by id
		local
			sorted_groups:SORTED_TWO_WAY_LIST[STRING]
			printed_keys: ARRAYED_LIST[INTEGER_64]
			sorted_keys: SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			create Result.make_empty
			if not groups.is_empty then
				create sorted_groups.make
				create printed_keys.make (groups.count)
				create sorted_keys.make
				sorted_keys.fill (groups.current_keys)
				from groups.start until groups.after loop
					sorted_groups.extend (groups.item_for_iteration.name)
					groups.forth
				end
				from sorted_groups.start until sorted_groups.after loop
					from sorted_keys.start until sorted_keys.after loop
						if attached groups.at (sorted_keys.item_for_iteration) as group then
							if group.name ~ sorted_groups.item and not printed_keys.has (sorted_keys.item_for_iteration) then
								Result.append("  " + sorted_keys.item_for_iteration.out + "->" + group.name + "%N")
								printed_keys.extend (sorted_keys.item_for_iteration)
							end
						end
						sorted_keys.forth
					end
					sorted_groups.forth
				end
			end
		end

	list_groups_for_out: STRING
		--lists all groups in the messenger system sorted by id
		local
			i:INTEGER
			group_keys: SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			create Result.make_empty
			if not groups.is_empty then
				create group_keys.make
				group_keys.fill (groups.current_keys)
				from
					i := 1
				until
					i > group_keys.count
				loop
					if attached groups.at (group_keys.at (i)) as group then
						Result.append("      " + group.id.out + "->" + group.name + "%N")
					end
					i := i + 1
				end
			end
		end


	list_users:STRING
		--lists all users in the messenger system sorted alphabetically, then sorted by id
		local
			sorted_users: SORTED_TWO_WAY_LIST[STRING]
			printed_keys: ARRAYED_LIST[INTEGER_64]
			sorted_keys: SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			create Result.make_empty
			if not users.is_empty then
				create sorted_users.make
				create printed_keys.make (users.count)
				create sorted_keys.make
				sorted_keys.fill (users.current_keys)
				from users.start until users.after loop
					sorted_users.extend (users.item_for_iteration.name)
					users.forth
				end
				from sorted_users.start until sorted_users.after loop
					from sorted_keys.start until sorted_keys.after loop
						if attached users.at (sorted_keys.item_for_iteration) as user then
							if user.name ~ sorted_users.item and not printed_keys.has (sorted_keys.item_for_iteration) then
								Result.append("  " + sorted_keys.item_for_iteration.out + "->" + user.name + "%N")
								printed_keys.extend (sorted_keys.item_for_iteration)
							end
						end
						sorted_keys.forth
					end
					sorted_users.forth
				end
			end
		end

	list_users_for_out:STRING
		--lists all users in the messenger system sorted by id
		local
			i:INTEGER
			user_keys:SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			create Result.make_empty
			if not users.is_empty then
				create user_keys.make
				user_keys.fill (users.current_keys)
				from
					i := 1
				until
					i > user_keys.count
				loop
					if attached users.at (user_keys.at (i)) as user then
						Result.append("      " + user.id.out + "->" + user.name + "%N")
					end
					i := i + 1
				end
			end
		end



feature--contract queries

	user_in_group(uid:INTEGER_64; gid:INTEGER_64): BOOLEAN
		--is user with 'uid' in the group with 'gid'?
		do
			if attached users.at (uid) as user and attached groups.at (gid) as group then
				Result := user.groups.has (group)
			else
				Result := false
			end
		end

	has_old_msg(uid:INTEGER_64; mid:INTEGER_64):BOOLEAN
		--does user with 'uid' have a message 'mid' in their old message box?
		do
			if attached users.at (uid) as user then
				Result := user.old_messages.has (mid)
			else
				Result := false
			end
		end

	authorized_to_read(uid:INTEGER_64; mid:INTEGER_64): BOOLEAN
		--is user with 'uid' authorized to read message 'mid'?
		require
			uid_exists: users.has (uid)
			mid_exists: messages.has (mid)
		do
			if attached users.at (uid) as user and attached messages.at (mid)as msg then
				if attached groups.at (msg.gid) as group then
					Result := user.groups.has (group)
				else
					Result := false
				end
			else
				Result := false
			end
		end

	message_is_new(uid:INTEGER_64; mid:INTEGER_64): BOOLEAN
		--does user with 'uid' have a new message 'mid'?
		do
			if attached users.at (uid) as user then
				Result := user.new_messages.has (mid)
			else
				Result := false
			end
		end

	message_sent(uid:INTEGER_64; gid:INTEGER_64; mid:INTEGER_64): BOOLEAN
		--was the message 'mid' sent to all users in the corresponding group 'gid'?
		do
			if attached groups.at (gid) as group then
				Result := true
				from
					group.users.start
				until
					group.users.after
				loop
					if not (group.users.item_for_iteration.id = uid) then
						Result := Result and group.users.item_for_iteration.new_messages.has (mid)
					elseif group.users.item_for_iteration.id = uid then
						Result := Result and group.users.item_for_iteration.old_messages.has (mid)
					end
					group.users.forth
				end
			end
		end

feature--output

	list_registrations: STRING
		--list all user registrations
		local
			i:INTEGER
			j:INTEGER
			user_keys: SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			create Result.make_empty
			if not users.is_empty then
				create user_keys.make
				user_keys.fill (users.current_keys)
				from
					i := 1
				until
					i > user_keys.count
				loop
					 if attached users.at (user_keys.at (i)) as user then
					 	if not user.groups.is_empty then
					 		Result.append("      [" + user.id.out + ", " + user.name + "]->{")
							from
								j := 1
							until
								j > user.groups.count
							loop
								if attached user.groups.at (j) as group then
									Result.append (group.id.out + "->" + group.name)
									if not (j = user.groups.count) then
										Result.append(", ")
									end
								end
								j := j + 1
							end
							Result.append("}%N")
					 	end
					 end
					i := i + 1
				end
			end
		end

	list_all_messages:STRING
		--list all messages in the system
        local
            temp:STRING
        do
                create Result.make_empty
                create temp.make_empty

                from
                    messages.start
                until
                    messages.after
                loop
                    Result.append ("      " + messages.item_for_iteration.mid.out + "->" )
                    Result.append ("[sender: " + messages.item_for_iteration.sender_id.out + ", group: " +  messages.item_for_iteration.gid.out + ", content: %"")
                        if messages.item_for_iteration.text.count > message_length then
                            temp.make_from_string (messages.item_for_iteration.text)
                            temp.remove_substring (message_length.as_integer_32 + 1, temp.count)
                            result.append (temp + "...%"]%N")
                        else
                            Result.append (messages.item_for_iteration.text + "%"]%N")
                        end
                    messages.forth
                end
        end

	message_state:STRING
		--list all the readability states of all messages.
		local
			user_keys:SORTED_TWO_WAY_LIST[INTEGER_64]
		do
			create Result.make_empty
			create user_keys.make

			user_keys.fill (users.current_keys)
			from
				messages.start
			until
				messages.after
			loop
				from
					user_keys.start
				until
					user_keys.after
				loop
					if attached users.at (user_keys.item_for_iteration) as a_users then
						Result.append ("      (" + a_users.id.out + ", " + messages.key_for_iteration.out + ")->")
						if a_users.new_messages.has (messages.key_for_iteration) then
							Result.append ("unread%N")
						elseif a_users.old_messages.has (messages.key_for_iteration) then
							Result.append ("read%N")
						else
							Result.append ("unavailable%N")
						end
					end
					user_keys.forth
				end
				messages.forth
			end
		end

	out:STRING
		--output system state
		do
			create Result.make_empty
			Result.append ("  Users:%N")
			Result.append (list_users_for_out)
			Result.append ("  Groups:%N")
			Result.append (list_groups_for_out)
			Result.append ("  Registrations:%N")
			Result.append (list_registrations)
			Result.append ("  All messages:%N")
			Result.append (list_all_messages)
			Result.append ("  Message state:%N")
			Result.append (message_state)
		end

invariant
		consistent_message_count: mid_count-1 = messages.count

		nonnegative_uids:
			across users as user_cr all
				user_cr.key > 0
			end

		nonnegative_gid:
			across groups as group_cr all
				group_cr.key > 0
			end

end


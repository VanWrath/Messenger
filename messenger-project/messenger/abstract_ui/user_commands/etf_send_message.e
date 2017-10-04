note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SEND_MESSAGE
inherit
	ETF_SEND_MESSAGE_INTERFACE
		redefine send_message end
create
	make
feature -- command
	send_message(uid: INTEGER_64 ; gid: INTEGER_64 ; txt: STRING)
		require else
			send_message_precond(uid, gid, txt)
    	do
    	-- perform some update on the model state
    		model.default_update
    		model.err_msg.error
			if (uid < 1 or gid < 1) then
				model.err_msg.id_not_positive
			elseif txt.is_empty then
				model.err_msg.msg_empty
			elseif not model.m.users.has (uid) then
				model.err_msg.user_dne
			elseif not model.m.groups.has (gid) then
				model.err_msg.group_dne
			elseif attached model.m.users.at (uid) as a_user and then across a_user.groups as a_group all a_group.item.id /= gid end then
				model.err_msg.auth_send
			else
				model.err_msg.ok
				model.err_msg.ok_message
				model.send_message (uid, gid, txt)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

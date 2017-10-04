note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_READ_MESSAGE
inherit
	ETF_READ_MESSAGE_INTERFACE
		redefine read_message end
create
	make
feature -- command
	read_message(uid: INTEGER_64 ; mid: INTEGER_64)
		require else
			read_message_precond(uid, mid)
    	do
			-- perform some update on the model state
    		model.default_update
			model.err_msg.error
    		if uid < 1 then
				model.err_msg.id_not_positive
			elseif mid < 1 then
				model.err_msg.id_not_positive
			elseif across model.m.users as u all u.key /= uid end then
				model.err_msg.user_dne
			elseif across model.m.messages as m all m.key /= mid end then
				model.err_msg.msg_dne
			elseif attached model.m.users.at (uid) as u and then (across u.new_messages as a_new_msg all a_new_msg.item.mid /= mid end and across u.old_messages as a_old_msg some a_old_msg.item.mid = mid end) then
				model.err_msg.already_read
			elseif attached model.m.users.at (uid) as u and then (across u.new_messages as a_new_msg all a_new_msg.item.mid /= mid end and across u.old_messages as a_old_msg all a_old_msg.item.mid /= mid end) then
				model.err_msg.auth_access 
			else
				model.err_msg.ok
				model.err_msg.ok_message
				model.read_message (uid, mid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

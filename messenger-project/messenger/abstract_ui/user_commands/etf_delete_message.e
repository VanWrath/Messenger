note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_DELETE_MESSAGE
inherit
	ETF_DELETE_MESSAGE_INTERFACE
		redefine delete_message end
create
	make
feature -- command
	delete_message(uid: INTEGER_64 ; mid: INTEGER_64)
		require else
			delete_message_precond(uid, mid)
    	do
			-- perform some update on the model state
			model.default_update
			model.err_msg.error
			if uid < 1 then
				model.err_msg.id_not_positive
			elseif not model.m.users.has (uid) then
				model.err_msg.user_dne

			elseif attached model.m.users.at (uid) as a_user and then
			not a_user.old_messages.has (mid) then
					model.err_msg.del_err


			else
				model.err_msg.ok
				model.err_msg.ok_message
				model.delete_message (uid, mid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

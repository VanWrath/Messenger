note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_OLD_MESSAGES
inherit
	ETF_LIST_OLD_MESSAGES_INTERFACE
		redefine list_old_messages end
create
	make
feature -- command
	list_old_messages(uid: INTEGER_64)
		require else
			list_old_messages_precond(uid)
    	do
    		-- perform some update on the model state
    		model.default_update
    		model.err_msg.error
    		if (uid < 1) then
    			model.err_msg.id_not_positive
			elseif across model.m.users as u all u.key /= uid end then
				model.err_msg.user_dne
    		else
    			model.err_msg.ok
    			model.err_msg.ok_message
				model.list_old_messages (uid)
    		end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

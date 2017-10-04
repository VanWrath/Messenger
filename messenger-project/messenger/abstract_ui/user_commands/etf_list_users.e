note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_USERS
inherit
	ETF_LIST_USERS_INTERFACE
		redefine list_users end
create
	make
feature -- command
	list_users
    	do
			-- perform some update on the model state
			model.default_update
    		model.err_msg.ok
    		model.err_msg.ok_message
    		if model.m.users.is_empty then
				model.err_msg.no_users
    		else
				model.list_users
    		end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIST_GROUPS
inherit
	ETF_LIST_GROUPS_INTERFACE
		redefine list_groups end
create
	make
feature -- command
	list_groups

    	do
    		-- perform some update on the model state
    		model.default_update
    		model.err_msg.ok
    		model.err_msg.ok_message
    		if model.m.groups.is_empty then
				model.err_msg.no_groups
    		else
				model.list_groups
    		end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

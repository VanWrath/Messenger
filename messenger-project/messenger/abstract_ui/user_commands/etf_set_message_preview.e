note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_SET_MESSAGE_PREVIEW
inherit
	ETF_SET_MESSAGE_PREVIEW_INTERFACE
		redefine set_message_preview end
create
	make
feature -- command
	set_message_preview(n: INTEGER_64)
    	do
    		-- perform some update on the model state
    		model.default_update
    		model.err_msg.error
    		if n < 1 then
				model.err_msg.prev_len
    		else
				model.err_msg.ok
				model.err_msg.ok_message
				model.set_message_preview (n)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

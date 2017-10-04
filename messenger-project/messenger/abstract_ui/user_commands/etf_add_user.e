note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_USER
inherit
	ETF_ADD_USER_INTERFACE
		redefine add_user end
create
	make
feature -- command
	add_user(uid: INTEGER_64 ; user_name: STRING)
		require else
			add_user_precond(uid, user_name)
			
    	do
			-- perform some update on the model state
			model.default_update
			model.err_msg.error
			if uid < 1 then
				model.err_msg.id_not_positive
			elseif across model.m.users as u some u.key = uid end then
				model.err_msg.id_in_use
			elseif user_name.count < 1 or not (user_name[1].is_alpha) then
				model.err_msg.user_start
			else
				model.err_msg.ok
				model.err_msg.ok_message
				model.add_user (uid, user_name)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end
end

note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REGISTER_USER
inherit
	ETF_REGISTER_USER_INTERFACE
		redefine register_user end
create
	make
feature -- command
	register_user(uid: INTEGER_64 ; gid: INTEGER_64)
		require else
			register_user_precond(uid, gid)
    	do
			-- perform some update on the model state
			model.default_update
			model.err_msg.error
			if uid < 1 then
				model.err_msg.id_not_positive
			elseif gid < 1 then
				model.err_msg.id_not_positive
			elseif across model.m.users as u all u.key /= uid end then
				model.err_msg.user_dne
			elseif across model.m.groups as g all g.key /= gid end then
				model.err_msg.group_dne
			elseif attached model.m.groups.at (gid) as g and then across g.users as gu some gu.item.id = uid end then
					model.err_msg.reg_exists
			else
				model.err_msg.ok
				model.err_msg.ok_message
				model.register_user (uid, gid)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end

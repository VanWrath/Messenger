note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ADD_GROUP
inherit
	ETF_ADD_GROUP_INTERFACE
		redefine add_group end
create
	make
feature -- command
	add_group(gid: INTEGER_64 ; group_name: STRING)
		require else
			add_group_precond(gid, group_name)
		do
			model.default_update
			model.err_msg.error
			if gid < 1 then
				model.err_msg.id_not_positive
			elseif across model.m.groups as g some g.key = gid end then
				model.err_msg.id_in_use
			elseif group_name.count < 1 or not (group_name[1].is_alpha) then
				model.err_msg.group_start
			else
				model.err_msg.ok
				model.err_msg.ok_message
				model.add_group (gid, group_name)
			end
			etf_cmd_container.on_change.notify ([Current])
		end
end

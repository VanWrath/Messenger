note
	description: "Summary description for {GROUP}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GROUP

inherit
	COMPARABLE


create
	make_with_name_and_id

feature {MESSENGER}
	make_with_name_and_id(group_name: STRING; gid: INTEGER_64)
		do
			name := group_name
			id := gid
			create users.make
		end

feature -- public attributes
	name:STRING
	id:INTEGER_64

feature {MESSENGER, ETF_MODEL, ETF_COMMAND} -- secure attributes

	users:SORTED_TWO_WAY_LIST[USER]

	add_user(user: USER)
		do
			users.extend (user)
		end

feature

	is_less alias "<" (other:like Current): BOOLEAN
		do
			if id < other.id then
				Result := true
			else
				Result := false
			end
		ensure then
			Result = (id < other.id)
		end
end

note
	description: "Summary description for {USER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USER

inherit
	COMPARABLE

create
	make_with_name_and_id

feature {MESSENGER}
	make_with_name_and_id(uname: STRING; uid: INTEGER_64)
		do
			name := uname
			id := uid
			create new_messages.make(10)
			create old_messages.make(10)
			create groups.make
		end

feature -- public attributes

	name:STRING
	id: INTEGER_64

feature {ETF_MODEL, MESSENGER, ETF_COMMAND} -- secure attributes

	new_messages: HASH_TABLE[MESSAGE, INTEGER_64]
	old_messages: HASH_TABLE[MESSAGE, INTEGER_64]
	groups:SORTED_TWO_WAY_LIST[GROUP]

feature {ETF_MODEL, MESSENGER, ETF_COMMAND} --secure commands

	add_group(a_group: GROUP)
		do
			groups.extend(a_group)
		end

	add_new_message(msg:MESSAGE; mid: INTEGER_64)
		do
			new_messages.extend (msg, mid)
		end

	read_message(mid:INTEGER_64)
		require
			mid_exists: new_messages.has (mid)
		do
			if attached new_messages.at (mid) as msg then
				old_messages.extend (msg, mid)
				new_messages.remove (mid)
			end

		ensure
			message_is_old: old_messages.has (mid)
			and (not new_messages.has (mid))

		end

feature --queries

	is_less alias "<" (other: like Current): BOOLEAN
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

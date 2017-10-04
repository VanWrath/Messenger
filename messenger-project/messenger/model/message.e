note
	description: "Summary description for {MESSAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGE

create
	make

feature {MESSENGER}
	make(in_text:STRING; m_id: INTEGER_64; g_id: INTEGER_64; s_id:INTEGER_64)
		do
			text := in_text
			mid := m_id
			gid := g_id
			sender_id := s_id
		end

feature {ETF_MODEL, MESSENGER, ETF_COMMAND}
	text:STRING
	mid:INTEGER_64
	gid: INTEGER_64
	sender_id: INTEGER_64
end

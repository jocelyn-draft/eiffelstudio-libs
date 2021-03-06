--|---------------------------------------------------------------
--|   Copyright (C) Interactive Software Engineering, Inc.      --
--|    270 Storke Road, Suite 7 Goleta, California 93117        --
--|                   (805) 685-1006                            --
--| All rights reserved. Duplication or distribution prohibited --
--|---------------------------------------------------------------

class SEQ_STRING inherit

	STRING
		rename
			precede as string_precede,
			prepend as string_prepend,
			mirrored as string_mirrored,
			mirror as string_mirror,
			share as string_share,
			wipe_out as string_wipe_out
		export
			sequential_representation
		undefine
			sequential_representation
		redefine
			has, contractable, remove_item
		end;

	LINEAR [CHARACTER]
		rename
			item as current_item,
			index_of as index_of_occurrence
		undefine
			out, twin, copy, is_equal
		redefine
			has, index_of_occurrence
		end;
	
	SEQUENCE [CHARACTER]
		rename
			item as current_item,
			index_of as index_of_occurrence,
			add as append_character,
			put as sequence_put,
			remove as remove_current_item,
			append as seq_append
		export
			{NONE} sequence_put, seq_append
		undefine
			search, search_equal, out, twin, copy, is_equal
		redefine
			has, index_of_occurrence,
			append_character
		select
			wipe_out
		end

creation

	make

feature -- Access

	current_item: CHARACTER is
			-- Current item
		do
			Result := item (index)
		end;
	
	has (c: CHARACTER): BOOLEAN is
			-- Does `Current' include `c'?
		do
			if not empty then
				Result := (index_of (c, 1) /= 0)
			end
		end;
	
	search_after (c: CHARACTER) is
			-- Move cursor to first position
			-- (at or after current cursor position)
			-- where `current_item' and `c' are identical.
		do
			if not off then
				index := index_of (c, index);
				if index = 0 then
					index := count + 1
				end
			end
		end;

	search_before (c: CHARACTER) is
			-- Move cursor to greatest position at or before cursor
			-- where `current_item' and `c' are identical;
			-- go offleft if unsuccessful.
		local
			str: like Current;
		do
			str := mirrored;
			if not str.off then
				index := count + 1 - str.index_of (c, str.index);
				if index = count + 1 then
					index := 0
				end
			end
		end;

	search_string_after (s: STRING; fuzzy: INTEGER) is
			-- Move cursor to first position
			-- (at or after cursor position) where `substring
			-- (index, index + s.count)' and `s' are identical.
			-- Go offright if unsuccessful. 
			-- The 'fuzzy' parameter is the maximum allowed number
			-- of mismatches within the pattern. A 0 means an exact match.
		local
			s_area: like area;
		do
			if not off then
				s_area := s.area;
				index := str_str (area, s_area, count,
						s.count, index, fuzzy);
				if index = 0 then
					index := count + 1
				end
			end
		end;

	search_string_before (s: STRING; fuzzy: INTEGER) is
			-- Move cursor to first position
			-- (at or before cursor position) where `substring
			-- (index, index + s.count)' and `s' are identical.
			-- Go offleft if unsuccessful.
			-- The 'fuzzy' parameter is the maximum allowed number
			-- of mismatches within the pattern. A 0 means an exact match.
		local
			s_mir_area, mir_area: like area;
			str_mirrored: like Current;
			s_mirrored: STRING;
		do
			if not off then
				str_mirrored := mirrored;
				s_mirrored := s.mirrored;
				s_mir_area := s_mirrored.area;
				mir_area := str_mirrored.area;
				index := count - str_str (mir_area, s_mir_area, count, s.count,
						str_mirrored.index, fuzzy) + 1;
				if index = count + 1 then
					index := 0
				end
			end
		end;

	index_of (c: CHARACTER; i: INTEGER): INTEGER is
			-- Index of the first occurrence of `c' equal or
			-- following the position `i'; 0 if not found.
		require
			index_small_enough: i <= count;
			index_large_enough: i > 0
		do
			Result := str_search ($area, $c, i, count)
		ensure
			Index_value: Result = 0 or item (Result) = c
		end;

	index_of_occurrence (c: CHARACTER; i: INTEGER): INTEGER is
			-- Index of `i'-th occurrence of `c'.
			-- 0 if none.
		local
			occurrences: INTEGER
		do
			if not empty then
				from
					Result := index_of (c, 1);
					if Result /= 0 then
						occurrences := 1
					end;
				until
					(Result = 0) or else (occurrences = i)
				loop
					if Result /= count then
						Result := index_of (c, Result + 1);
						if Result /= 0 then
							occurrences := occurrences + 1
						end
					else
						Result := 0
					end;
				end
			end
		ensure then
			Index_value: (Result = 0) or item (Result) = c
		end;
 
feature -- Insertion

	replace (c: CHARACTER) is
			-- Replace current item by `c'.
		do 
			put (c, index)
		end;

	precede (c: CHARACTER) is
			-- Add `c' at front.
		do
			string_precede (c);
			index := index + 1;
--		ensure
--			New_index: index = old index + 1;
		end;

	prepend (s: STRING) is
			-- Prepend a copy of `s' at front of `Current'.
		require
			argument_not_void: s /= Void
		do
			string_prepend (s);
			index := index + s.count;
--		ensure
--			New_index: index = old index + s.count;
		end;

feature -- Deletion

	remove_item (c: CHARACTER) is
			-- Remove `c' from `Current'.
		local
			i: INTEGER
		do
			if count /= 0 then
				i := index_of (c, 1);
				if i /= 0 then
					remove (i)
				end
			end
		end;

	remove_current_item is
			-- Remove current item.
		do
			remove (index)
		end;

	wipe_out is
			-- Clear out `Current'.
		do
			string_wipe_out;
			index := 0;
		end;

	contractable: BOOLEAN is
			-- May items by removed from `Current'?
		do
			Result := not off
		end;

feature -- Transformation

	mirrored: like Current is
			-- Current string read from right to left.
			-- The returned string has the same `capacity' and the
			-- same current position (i.e. the cursor is pointing
			-- at the same item)
		do
			Result := string_mirrored;
			if not after then
				from
					Result.start
				until
					Result.index = count - index + 1
				loop
					Result.forth
				end;
			end;
		ensure
			mirrored_index: Result.index = count - index + 1;
			same_count: Result.count = count;
		--  reverse_entries:
		--	for all `i: 1..count, Result.item (i) = item (count + 1 - i)'
		end;

	mirror is
			-- Reverse the characters order.
			-- "Hello world" -> "dlrow olleH".
			-- The current position will be on the same item
			-- as before.
		do
			string_mirror;
			index := count + 1 - index;
		ensure
		--  same_count: count = old count;
		--  mirrored_index: index = count - old index + 1;
		--  reverse_entries:
		--	for all `i: 1..count, item (i) = old item (count + 1 - i)'
		end;

	share (other: like Current) is
			-- Make `Current' share the text of `other'.
		require
			argument_not_void: other /= Void
		do
			string_share (other);
			index := other.index;
		ensure
			Shared_index: other.index = index;
		end;

feature -- Cursor

	start is
			-- Move to first position.
		do
			index := 1
		end;

	finish is
			-- Move to last position.
		do
			index := count
		end;

	back is
			-- Move to previous position.
		do
			index := index - 1
		end;

	forth is
			-- Move to next position.
		do
			index := index + 1
		end;

	before: BOOLEAN is
			-- Is there no position to the left of the cursor?
		do
			Result := index < 1
		end;

	after: BOOLEAN is
			-- Is there no position to the right of the cursor?
		do
			Result := index > count
		end;

	index: INTEGER;
			-- Index of `current_item', if valid
			-- Valid values are between 1 and `count' (if `count' > 0).

invariant

	contractable = not off;
	extensible = true

end

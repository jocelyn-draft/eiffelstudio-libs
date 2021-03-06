--|---------------------------------------------------------------
--|   Copyright (C) Interactive Software Engineering, Inc.      --
--|    270 Storke Road, Suite 7 Goleta, California 93117        --
--|                   (805) 685-1006                            --
--| All rights reserved. Duplication or distribution prohibited --
--|---------------------------------------------------------------

-- Garbage collector statistics
-- TIme accouting is relevant only if `enable_time_accounting'
-- has been called in MEMORY

indexing

	date: "$Date$";
	revision: "$Revision$"

class GC_INFO

inherit

	MEM_CONST

creation

	make

feature

	cycle_count: INTEGER;
			-- Number of collection cycles for `type' and before last call to
			-- `update'
	
	memory_used: INTEGER;
			-- Total number of bytes used (counting overhead) after the last
			-- cycle for `type' and before last call to `update'

	collected: INTEGER;
			-- Number of bytes collected by the last cycle,
			-- for `type' and before last call to `update'
	
	collected_average: INTEGER;
			-- Average number of bytes collected by a cycle,
			-- for `type' and before last call to `update'
	
	real_time: INTEGER;
			-- Number of centi-seconds used by last cycle (real time),
			-- for `type' and before last call to `update'
			-- n.b: This may not be accurate on systems which do not provide a
			-- sub-second accuracy clock (typically provided on BSD)

	real_time_average: INTEGER;
			-- Average amount of real time, in centi-seconds, spent in the
			-- collection cycle,
			-- for `type' and before last call to `update'
	
	real_interval_time: INTEGER;
			-- Real interval time (as opposed to CPU time) between two
			-- automatically raised cycles, in centi-seconds,
			-- for `type' and before last call to `update'
	
	real_interval_time_average: INTEGER;
			-- Average real interval time between two automatic cycles,
			-- in centi-seconds,
			-- for `type' and before last call to `update
	
	cpu_time: DOUBLE;
			-- Amount of CPU time, in seconds, spent in cycle,
			-- for `type' and before last call to `update
	
	cpu_time_average: DOUBLE;
			-- Average amount of CPU time spent in cycle, in seconds.,
			-- for `type' and before last call to `update

	cpu_interval_time: DOUBLE;
			-- Amount of CPU time elapsed since between the last and the
			-- penultimate cycle.,
			-- for `type' and before last call to `update

	cpu_interval_time_average: DOUBLE;
			-- Average amount of CPU time between two cycles,
			-- for `type' and before last call to `update
	
	sys_time: DOUBLE;
			-- Amount of kernel time, in seconds, spent in cycle,
			-- for `type' and before last call to `update
	
	sys_time_average: DOUBLE;
			-- Average amount of kernel time spent in cycle,
			-- for `type' and before last call to `update
	
	sys_interval_time: DOUBLE;
			-- Amount of kernel time elapsed since between the last and the
			-- penultimate cycle,
			-- for `type' and before last call to `update

	sys_interval_time_average: DOUBLE;
			-- Average amount of kernel time between two cycles,
			-- for `type' and before last call to `update

	type: INTEGER;
			-- Collector type (Full, Collect),
			-- for `type' and before last call to `update

	make, update (memory: INTEGER) is
			-- Fill in statistics for `memory' type
		do
			gc_stat (memory);
			cycle_count := gc_info (0);
			memory_used := gc_info (1);
			collected := gc_info (2);
			collected_average := gc_info (3);
			real_time := gc_info (4);
			real_time_average := gc_info (5);
			real_interval_time := gc_info (6);
			real_interval_time_average := gc_info (7);
			cpu_time := gc_infod (8);
			cpu_time_average := gc_infod (9);
			cpu_interval_time := gc_infod (10);
			cpu_interval_time_average := gc_infod (11);
			sys_time := gc_infod (12);
			sys_time_average := gc_infod (13);
			sys_interval_time := gc_infod (14);
			sys_interval_time_average := gc_infod (15);
		end;
	
feature {NONE}

	gc_stat (mem: INTEGER) is
			-- Initialize run-time buffer used by gc_info to retrieve the
			-- statistics frozen at the time of this call.
		external
			"C"
		end;

	gc_info (field: INTEGER): INTEGER is
			-- Read GC accounting structure, field by field.
		external
			"C"
		end;

	gc_infod (field: INTEGER): DOUBLE is
			-- Read GC accounting structure, field by field.
		external
			"C"
		end

end

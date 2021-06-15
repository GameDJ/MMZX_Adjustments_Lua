adr_model = 0x0214FC74
adr_px_kunai_angles = 0x0218BA1C
adr_grounded_state = 0x0214FB19 --0=ground, 1=air, 2=wall
adr_px_num_kunai_in_last = 0x0214FE0A

kunai_r_state = -1
kunai_y_state = -1
function px_kunai_spread_control_old2 (e)
	if e then
		if memory.readbyte(adr_model) == 6 and memory.readbyte(adr_grounded_state) == 1 then
			if joypad.get(1).Y then
				if kunai_y_state == -1 then
					kunai_y_state = 0
				elseif kunai_y_state == 0 then
					memory.writedword(adr_px_kunai_angles, 807407616)
					kunai_y_state = 1
				end
				--R will override Y if pressed on the same frame or later
				if kunai_r_state == 0 and kunai_y_state > -1 then
					kunai_y_state = -1
				end
			elseif kunai_y_state == 1 then
				kunai_y_state = -1
			end
			if joypad.get(1).R then
				if kunai_r_state == -1 then
					kunai_r_state = 0
				elseif kunai_r_state == 0 then
					memory.writedword(adr_px_kunai_angles, 0)
					kunai_r_state = 1
				elseif kunai_y_state == 0 then
					kunai_r_state = -1 --Y will override R if Y pressed after R
				end
			elseif kunai_r_state == 1 then
				kunai_r_state = -1
			end
		end
		print("y: " .. kunai_y_state)
		print("r: " .. kunai_r_state)
	end
end

kunai_r_frames = -1
kunai_y_frames = -1
function px_kunai_spread_control (e)
	if e then
		if memory.readbyte(adr_model) == 6 then
			if joypad.get(1).R then
				if kunai_r_frames < 3 then
					kunai_r_frames = kunai_r_frames + 1
				end
			elseif kunai_r_frames > -1 then
				kunai_r_frames = -1
			end
			if joypad.get(1).Y then
				if kunai_y_frames < 3 then
					kunai_y_frames = kunai_y_frames + 1
				end
			elseif kunai_y_frames > -1 then
				kunai_y_frames = -1
			end
			if memory.readbyte(adr_px_num_kunai_in_last) == 0 then
				if kunai_r_frames > -1 and kunai_r_frames < 3 then
					memory.writedword(adr_px_kunai_angles, 0)
					kunai_r_frames = 3 --so that this only happens for 1 frame
				elseif kunai_y_frames > -1 and kunai_y_frames < 3 then
					memory.writedword(adr_px_kunai_angles, 807407616)
					kunai_y_frames = 3 --so that this only happens for 1 frame
				end
			end
		end
	end
end
while true do
	px_kunai_spread_control(true)
	
	emu.frameadvance()
end
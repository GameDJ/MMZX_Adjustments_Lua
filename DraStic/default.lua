-- Model Adjustment Pack v2.2.0 by Meta_X --
-- For Mega Man ZX on DraStic emulator for Android --
--List of changes (disable them by changing the "true" values at the bottom of this script to false):
--All: Give 1 Weapon Energy to all models every 3 seconds, and refill WE completely at transervers or upon death
--     Switch to any model using Select+[button] combinations (replaces an AR script that DraStic doesn't support)
--X: Can switch elements with overdrive button, VERY EXPERIMENTAL!! Do not recommend
--FX: Can perform a recoil-rod style superjump by pressing B while using Ground Breaker
--    Can also perform a double jump by holding down while releasing a charge fireball in the air
--    Ground Breaker now multihits vs bosses and can be performed from a lv1 charge
--LX: Can now perform a skullcrush like Model ZX by holding down during jumpslash [planned: deals extra damage]
--    Ice dragon can be performed from a lv1 charge and costs 2 fewer energy points
--    Ice sled now instantly accelerates to full speed when hit
--PX: Can spend 1 WE to perform a MMX6 Shadow Armor-style highjump by pressing Up and B
--    Can throw kunai straight forward by pressing R (press Y for the usual kunai spread)
--OX: [planned: Skullcrush buffed to do extra damage like it's supposed to]
--OX, ZX and X: Can perform a small double jump (or full double jump for overdrive OX) (X and ZX off by default)
--
--Known issues:
--Very risky to reset game or load another save with script running. Disable it before switching then run it again while playing the new file
--Currently assumes control scheme (B is jump, main weapon is Y and sub is R)
--Models you haven't yet switched to with the script active can appear on the menu as filling past their cap
--Double jump (and the other custom jump abilities) can have some strange behavior around ceilings
--Walljumping while not sliding uses up your doublejump
--Cannot drop through a platform then double jump and land on that same platform
--You must use a different attack before being able to FX superjump again (eg. plain bullet), and it has trouble working on certain terrain
--Ice dragon early charge doesn't always work like if released during a cutscene
--Element switch only works against bosses and is constantly activating and doesnt transfer properly and... just don't use it cept to mess around lol


--Addresses; dont forget to use memory.read/write()
if not jp then --en
	adr_equipped_chips = 0x0214FCAC --400 guess
	adr_model = 0x0214FC74
	adr_definite_model = 0x020F73AC
	adr_current_model_WE_cap = 0x02150275
	adr_HX_WE = 0x0214FC95
	adr_FX_WE = 0x0214FC96
	adr_LX_WE = 0x0214FC97
	adr_PX_WE = 0x0214FC98
	adr_current_model_WE = 0x02150271
	adr_grounded_state = 0x0214FB19 --0=ground, 1=air, 2=wall
	adr_overdrive = 0x0214FC2D
	adr_x_vel = 0x0214FB6D
	adr_y_vel = 0x0214FB71
	adr_y_vel_something_1 = 0x0214FB72
	adr_y_vel_something_2 = 0x0214FB73
	adr_last_ability_id = 0x0214FC36
	adr_action_id = 0x0214FC48
	adr_x_pos = 0x0214FB64
	adr_y_pos = 0x0214FB68
	--adr_last_platform_y = 0x020F1FD4 --probably not legit
	adr_main_charge = 0x0214FC38
	adr_sub_charge = 0x0214FC39
	adr_lx_sled_1_vel = 0x02150894 --
	adr_lx_sled_2_vel = 0x021507C4 --
	adr_lx_sled_3_vel = 0x021506F4 --
	adr_px_kunai_angles = 0x0218BA1C
	adr_px_num_kunai_in_last = 0x0214FE0A
	adr_priority = 0x0215109E
	adr_x_palette = 0x020DE7C6
	adr_current_model_palette = 0x020F5C4A --starts on first non-transparent color
	adr_camera_x = 0x0214F62C --center of screen
	adr_camera_y = 0x0214F630 --center of screen
	adr_animation = 0x0214FB80 --animation id
	adr_anim_frame = 0x0214FB81 --current frame of animation
	adr_anim_frame_timer = 0x0214FB82 --how many frames til next anim frame
	adr_current_room = 0x02108228
	adr_something_transerver = 0x0214FC48 --actually some sorta animation id but 27 is used when transerver
	--adr_player_hp = 0x
	adr_weapon_bindings = 0x0214FC80 --each word is each model's main/sub wep ending in OX at EN:0214FC8E. Hu:00, X:01, ZX-saber:02, ZX-buster:03, HX-slash:04, HX-slice:05, FX-left:06, FX-right:07, LX:08, PX:09, OX-saber:0A, OX-buster:0B
	adr_control_bindings = 0x0214FCB8--each word is a button starting here ending with overdrive at EN:0214FCC2: main, sub, jump, dash, transform, overdrive. buttons: A:0001, B:0002, R:0100, L:0200, X:0400, Y:0800
	adr_control_type = 0x0214FCC4 --0 type A, 1 type B, 2 custom
	adr_pause_menu_page = 0x0215F01D --0 thru 4 starting at main
	adr_dash_frames_remaining = 0x0214FC30 --previous byte also controls dashing; 4 for hx post-airdash
	
	adr_final_attack_slot_attack_id = 0x02159231
	adr_final_attack_slot_angle = 0x02159248
	adr_final_attack_slot_x = 0x02159278
	adr_final_attack_slot_y = 0x0215927C
	adr_final_attack_slot_direction = 0x02159282
	adr_final_attack_slot_overdrive = 0x021592CE
	adr_final_attack_slot_element = 0x021592D0
	adr_final_attack_slot_primary = 0x0215921D --was "active" but realized it only applies to 1 at a time
	adr_final_attack_slot_active = 0x02159226 --if val modulus 0x10 == 0xF then active (unless 8F?), otherwise 0xA
	adr_final_attack_slot_anim_frame = 0x02159295
else --jp
	adr_equipped_chips = 0x0214F8AC
	adr_model = 0x0214F874
	adr_definite_model = 0x020F457C --not same thing as en one but should work
	adr_current_model_WE_cap = 0x0214FE75
	adr_HX_WE = 0x0214F895
	adr_FX_WE = 0x0214F896
	adr_LX_WE = 0x0214F897
	adr_PX_WE = 0x0214F898
	adr_current_model_WE = 0x0214FE71
	adr_grounded_state = 0x0214F719
	adr_overdrive = 0x0214F82D
	adr_x_vel = 0x0214F76D
	adr_y_vel = 0x0214F771
	adr_y_vel_something_1 = 0x0214F772
	adr_y_vel_something_2 = 0x0214F773
	adr_last_ability_id = 0x0214F836
	adr_action_id = 0x0214F848
	adr_y_pos = 0x0214F768
	--adr_last_platform_y = 0x020F1FD4 --havent checked
	adr_main_charge = 0x0214F838
	adr_sub_charge = 0x0214F839
	adr_lx_sled_1_vel = 0x02150494
	adr_lx_sled_2_vel = 0x021503C4
	adr_lx_sled_3_vel = 0x021502F4
	adr_px_kunai_angles = 0x0218BA1C
	adr_px_num_kunai_in_last = 0x0214FA0A
	adr_priority = 0x02150C9E
	adr_x_palette = 0x020DA9E2
	adr_current_model_palette = 0x020F79CA
	--adr_camera_x = 
	--adr_camera_y
	adr_animation = 0x0214F780 --animation id
	adr_anim_frame = 0x0214F781 --current frame of animation
	adr_anim_frame_timer = 0x0214F782 --how many frames til next anim frame
	adr_current_room = 0x02107E28
	adr_something_transerver = 0x0214F848 --actually some sorta animation id but 27 is used when transerver
	--adr_player_hp = 0x
	adr_weapon_bindings = 0x0214F880
	adr_control_bindings = 0x0214F8B8
	adr_control_type = 0x0214F8C4
	adr_pause_menu_page = 0x0215EC1D --0 thru 4 starting at main
	adr_dash_frames_remaining = 0x0214F830
	
	adr_final_attack_slot_attack_id = 0x02159201
	adr_final_attack_slot_angle = 0x02159218
	adr_final_attack_slot_x = 0x02159248
	adr_final_attack_slot_y = 0x0215924C
	adr_final_attack_slot_direction = 0x02159252
	adr_final_attack_slot_overdrive = 0x0215929E
	adr_final_attack_slot_element = 0x021592A0
	adr_final_attack_slot_primary = 0x021591ED --was "active" but realized it only applies to 1 at a time
	adr_final_attack_slot_active = 0x021591F6 --if val modulus 0x10 == 0xF then active (unless 8F?), otherwise 0xA
	adr_final_attack_slot_anim_frame = 0x02159265
end
--same for en/jp

function on_load(game)
	--Hopefully this is consistent for determining game version :P
	if drastic.get_ds_memory_arm9_16(0x0200000F) == 0x333B then
		jp = false
		--print("en")
	else
		jp = true
		--print("jp")
	end
end

function on_unload()
end

-A:0001, B:0002, R:0100, L:0200, X:0400, Y:0800
--main, sub, jump, dash, transform, overdrive
controls = {'Y', 'R', 'B', 'L', 'X', 'A'}
function read_controls ()
	if drastic.get_ds_memory_arm9_8(adr_control_type) == 0 then --type A
		controls = {'Y', 'R', 'B', 'L', 'X', 'A'}
	elseif drastic.get_ds_memory_arm9_8(adr_control_type) == 1 then --type B
		controls = {'Y', 'X', 'B', 'A', 'L', 'R'}
	else --custom
		local button
		for i=1,6,1 do
			button = drastic.get_ds_memory_arm9_16(adr_control_type - 14 + i*2)
			if button == 0x0001 then
				controls[i] = 'A'
			elseif button == 0x0002 then
				controls[i] = 'B'
			elseif button == 0x0100 then
				controls[i] = 'R'
			elseif button == 0x0200 then
				controls[i] = 'L'
			elseif button == 0x0400 then
				controls[i] = 'X'
			elseif button == 0x0800 then
				controls[i] = 'Y'
			end
		end
	end
end
function read_button (action)
	local action_index
	if action == "main" then
		action_index = 1
	elseif action == "sub" then
		action_index = 2
	elseif action == "jump" then
		action_index = 3
	elseif action == "dash" then
		action_index = 4
	elseif action == "transform" then
		action_index = 5
	elseif action == "overdrive" then
		action_index = 6
	end
	if controls[action_index] == "A" then
		return (buttons & drastic.C.BUTTON_A) ~= 
	elseif controls[action_index] == "B" then
		return (buttons & drastic.C.BUTTON_B) ~= 
	elseif controls[action_index] == "R" then
		return (buttons & drastic.C.BUTTON_R) ~= 
	elseif controls[action_index] == "L" then
		return (buttons & drastic.C.BUTTON_L) ~= 
	elseif controls[action_index] == "X" then
		return (buttons & drastic.C.BUTTON_X) ~= 
	elseif controls[action_index] == "Y" then
		return (buttons & drastic.C.BUTTON_Y) ~= 
	end
	return false
end

function determine_quickcharge_equipped (n)
	if n == nil then
		n = 128
		chip_value = drastic.get_ds_memory_arm9_8(adr_equipped_chips)
	end
	if (chip_value - n) >= 0 then
		chip_value = chip_value - n
		if n == 8 then
			n = nil
			return true
		end
	end
	if n == 0 then --if reached end, return false
		n = nil
		return false
	end
	return determine_quickcharge_equipped(math.floor(n/2))
end

--just used within other functions for determining needed charge times
function quickcharge(lvl) --paramater 1 for lvl 1 charge or 2 for lvl2
	if determine_quickcharge_equipped() == false then
		if lvl == 2 then
			return 120
		else
			return 40
		end
	else
		if lvl == 2 then
			return 96
		else
			return 32
		end
	end
end

autofill_frame_count = 0
hxcap = 32
fxcap = 32
lxcap = 32
pxcap = 32
function autofill_energy (e)
	if e then
		--record WE cap for each model since we can only see equipped's cap
		if drastic.get_ds_memory_arm9_8(adr_model) == 3 then
			hxcap = drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4;
		elseif drastic.get_ds_memory_arm9_8(adr_model) == 4 then
			fxcap = drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4;
		elseif drastic.get_ds_memory_arm9_8(adr_model) == 5 then
			lxcap = drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4;
		elseif drastic.get_ds_memory_arm9_8(adr_model) == 6 then
			pxcap = drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4;
		end
		
		if drastic.get_ds_memory_arm9_8(adr_HX_WE) < 32 or drastic.get_ds_memory_arm9_8(adr_FX_WE) < 32 or drastic.get_ds_memory_arm9_8(adr_LX_WE) < 32 or drastic.get_ds_memory_arm9_8(adr_PX_WE) < 32 then --if any of HX, FX, LX, or PX has less than 32 (so count isnt always going)
			if autofill_frame_count < 180 then --number of frames til energy point
				autofill_frame_count = autofill_frame_count + 1
			else --if each model's WE less than assumed cap and not currently equipped, add WE point
				if drastic.get_ds_memory_arm9_8(adr_HX_WE) < hxcap then --HX
					drastic.set_ds_memory_arm9_8(adr_HX_WE, drastic.get_ds_memory_arm9_8(adr_HX_WE) + 1)
				end
				if drastic.get_ds_memory_arm9_8(adr_FX_WE) < fxcap then --FX
					drastic.set_ds_memory_arm9_8(adr_FX_WE, drastic.get_ds_memory_arm9_8(adr_FX_WE) + 1)
				end
				if drastic.get_ds_memory_arm9_8(adr_LX_WE) < lxcap then --LX
					drastic.set_ds_memory_arm9_8(adr_LX_WE, drastic.get_ds_memory_arm9_8(adr_LX_WE) + 1)
				end
				if drastic.get_ds_memory_arm9_8(adr_PX_WE) < pxcap then --PX
					drastic.set_ds_memory_arm9_8(adr_PX_WE, drastic.get_ds_memory_arm9_8(adr_PX_WE) + 1)
				end
				autofill_frame_count = 0
			end
		end
		
		--if equipped model's WE is higher than its cap, reduce to cap
		if drastic.get_ds_memory_arm9_8(adr_current_model_WE) > drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4 then
			if drastic.get_ds_memory_arm9_8(adr_model) == 3 then --if HX
				drastic.set_ds_memory_arm9_8(adr_HX_WE, drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4)
			end
			if drastic.get_ds_memory_arm9_8(adr_model) == 4 then --if FX
				drastic.set_ds_memory_arm9_8(adr_FX_WE, drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4)
			end
			if drastic.get_ds_memory_arm9_8(adr_model) == 5 then --if LX
				drastic.set_ds_memory_arm9_8(adr_LX_WE, drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4)
			end
			if drastic.get_ds_memory_arm9_8(adr_model) == 6 then --if PX
				drastic.set_ds_memory_arm9_8(adr_PX_WE, drastic.get_ds_memory_arm9_8(adr_current_model_WE_cap)*4)
			end
		end
		
		--refill at transerver
		if drastic.get_ds_memory_arm9_8(adr_current_room) == 70 and drastic.get_ds_memory_arm9_8(adr_something_transerver) == 27 and (drastic.get_ds_memory_arm9_8(adr_HX_WE) < hxcap or drastic.get_ds_memory_arm9_8(adr_FX_WE) < fxcap or drastic.get_ds_memory_arm9_8(adr_LX_WE) < lxcap or drastic.get_ds_memory_arm9_8(adr_PX_WE) < pxcap) then
			drastic.set_ds_memory_arm9_8(adr_HX_WE, hxcap)
			drastic.set_ds_memory_arm9_8(adr_FX_WE, fxcap)
			drastic.set_ds_memory_arm9_8(adr_LX_WE, lxcap)
			drastic.set_ds_memory_arm9_8(adr_PX_WE, pxcap)
		end
		--refill upon death
		if drastic.get_ds_memory_arm9_8(adr_grounded_state) == 10 and drastic.get_ds_memory_arm9_8(adr_player_hp) == 0 and death_timer == -1 then
			death_timer = 1
		elseif drastic.get_ds_memory_arm9_8(adr_grounded_state) == 10 and drastic.get_ds_memory_arm9_8(adr_player_hp) == 0 and death_timer > 0 then
			death_timer = death_timer + 1
			if death_timer == 80 then
				drastic.set_ds_memory_arm9_8(adr_HX_WE, hxcap)
				drastic.set_ds_memory_arm9_8(adr_FX_WE, fxcap)
				drastic.set_ds_memory_arm9_8(adr_LX_WE, lxcap)
				drastic.set_ds_memory_arm9_8(adr_PX_WE, pxcap)
				death_timer = 0 --set to 0 so stop incrementing, then later will set to -1 for reset
			end
		elseif death_timer > -1 and not drastic.get_ds_memory_arm9_8(adr_grounded_state) == 10 and not drastic.get_ds_memory_arm9_8(adr_player_hp) == 0 then
			death_timer = -1
		end
	end
end

double_jump_frame_count = -1
jump_pressed = false
double_jump_remaining = false
jump_override = false
function double_jump (buttons, ox, zx, x)
	if ox or zx or x then
		if (drastic.get_ds_memory_arm9_8(adr_model) == 1 and x) or (drastic.get_ds_memory_arm9_8(adr_model) == 2 and zx) or (drastic.get_ds_memory_arm9_8(adr_model) == 7 and ox) then
			if double_jump_remaining and read_button("jump") and (drastic.get_ds_memory_arm9_8(adr_grounded_state) ~= 0 and drastic.get_ds_memory_arm9_8(adr_grounded_state) ~= 2) then
				jump_pressed = true
			end
			if (drastic.get_ds_memory_arm9_8(adr_grounded_state) == 0 or drastic.get_ds_memory_arm9_8(adr_grounded_state) == 2 or drastic.get_ds_memory_arm9_8(adr_grounded_state) == 3) and read_button("jump") then
				jump_override = true
			end
			if not read_button("jump") then
				jump_override = false
			end
			if not double_jump_remaining and (drastic.get_ds_memory_arm9_8(adr_grounded_state) == 0 or drastic.get_ds_memory_arm9_8(adr_grounded_state) == 2) then
				double_jump_remaining = true
			end
			if double_jump_remaining and jump_pressed and double_jump_frame_count == -1 and not jump_override and drastic.get_ds_memory_arm9_8(adr_grounded_state) == 1 then
				if drastic.get_ds_memory_arm9_8(adr_overdrive) == 65 or drastic.get_ds_memory_arm9_8(adr_overdrive) == 67 then --if overdrived, do a higher jump
					double_jump_frame_count = 0
				else
					double_jump_frame_count = 3
				end
				double_jump_remaining = false
				--drastic.set_ds_memory_arm9_32(adr_last_platform_y, 33827805) doesnt work :(
			end
			if double_jump_frame_count > -1 then
				if double_jump_frame_count < 19 then
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, -1)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, -1)
					if not read_button("jump") then
						drastic.set_ds_memory_arm9_8(adr_y_vel, 0)
						double_jump_frame_count = 19
						drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, 0)
						drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, 0)
					elseif double_jump_frame_count < 3 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -5)
					elseif double_jump_frame_count < 7 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -4)
					elseif double_jump_frame_count < 11 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -3)
					elseif double_jump_frame_count < 15 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -2)
					elseif double_jump_frame_count < 19 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -1)
					end
					double_jump_frame_count = double_jump_frame_count + 1
				else
					double_jump_frame_count = -1
					drastic.set_ds_memory_arm9_8(adr_y_vel, 0)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, 0)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, 0)
				end
			end
			if jump_pressed then
				jump_pressed = false
			end
		else
			if double_jump_frame_count ~= -1 then
				double_jump_frame_count = -1
			end
			if double_jump_remaining == true then
				double_jump_remaining = false
			end
			if jump_override == true then
				jump_override = false
			end
		end
	end
	return buttons
end

--sorry this one's a horror show...... but, it works :P
ground_punch_frame_count = -1
ground_punch_jump_attack_cooldown = false
ground_punch_jump_landing_cooldown = false
ground_punch_animation_frame_count = -1
function fx_ground_breaker_jump (buttons, e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 4 then
			if ground_punch_jump_attack_cooldown and not (drastic.get_ds_memory_arm9_8(adr_action_id) == 76 or drastic.get_ds_memory_arm9_8(adr_action_id) == 77) and ground_punch_frame_count == -1 then
				ground_punch_jump_attack_cooldown = false --attack must end
			end
			if ground_punch_jump_landing_cooldown and drastic.get_ds_memory_arm9_8(adr_grounded_state) == 0 and ground_punch_frame_count == -1 then
				ground_punch_jump_landing_cooldown = false --must land before jumping again
			end
			--print(ground_punch_jump_attack_cooldown)
			--print(ground_punch_jump_landing_cooldown)
			--print("frame ".. ground_punch_frame_count)
			--print("anim ".. ground_punch_animation_frame_count)
			if (drastic.get_ds_memory_arm9_8(adr_last_ability_id) == 62 or drastic.get_ds_memory_arm9_8(adr_last_ability_id) == 63) and (drastic.get_ds_memory_arm9_8(adr_action_id) >= 0x74 and drastic.get_ds_memory_arm9_8(adr_action_id) <= 0x77) and ground_punch_frame_count == -1 and not ground_punch_jump_attack_cooldown and not ground_punch_jump_landing_cooldown and drastic.get_ds_memory_arm9_8(adr_grounded_state) == 0 and ground_punch_animation_frame_count == -1 then
				ground_punch_animation_frame_count = 0
				ground_punch_jump_attack_cooldown = true
			end
			if ground_punch_animation_frame_count > -1 then
				if ground_punch_animation_frame_count < 30 then
					ground_punch_animation_frame_count = ground_punch_animation_frame_count + 1
				else
					ground_punch_animation_frame_count = -1
				end
			end
			if ground_punch_animation_frame_count > 8 and read_button("jump") and not ground_punch_jump_landing_cooldown then
				ground_punch_frame_count = 0
				ground_punch_jump_attack_cooldown = true
				ground_punch_jump_landing_cooldown = true
			end
			if ground_punch_frame_count > -1 then
					if ground_punch_frame_count < 30 then -- 19 + 8 frames
						drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, -1)
						drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, -1)
						if ground_punch_frame_count == 0 then --must force first movement :/
							drastic.set_ds_memory_arm9_32(adr_y_pos, drastic.get_ds_memory_arm9_32(adr_y_pos) - 256*18)
							drastic.set_ds_memory_arm9_8(adr_last_ability_id + 1, 0) --end something with endlag timer
						end
						if ground_punch_frame_count < 2 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -8)
						elseif ground_punch_frame_count < 6 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -7)
						elseif ground_punch_frame_count < 10 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -6)
						elseif ground_punch_frame_count < 14 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -5)
						elseif ground_punch_frame_count < 18 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -4)
						elseif ground_punch_frame_count < 22 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -3)
						elseif ground_punch_frame_count < 26 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -2)
						elseif ground_punch_frame_count < 30 then
							drastic.set_ds_memory_arm9_8(adr_y_vel, -1)
						end
					ground_punch_frame_count = ground_punch_frame_count + 1
					else
						ground_punch_frame_count = -1
						drastic.set_ds_memory_arm9_8(adr_y_vel, 0)
						drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, 0)
						drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, 0)
					end
			end
		else
			if ground_punch_frame_count ~= -1 then
				ground_punch_frame_count = -1
			end
			if ground_punch_jump_attack_cooldown then
				ground_punch_jump_attack_cooldown = false
			end
		end
	end
	return buttons
end

downward_fireball_frames = -1
downward_fireball_slot = 0
downward_fireball_start_x = 0
downward_fireball_start_y = 0
downward_fireball_direction = 0 -- 1 if right, -1 if left
downward_fireball_remaining = false
function fx_aerial_punch_jump (buttons, e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 4 then
			if downward_fireball_frames == -1 and downward_fireball_remaining and (buttons & drastic.C.BUTTON_DOWN) ~= 0 and (drastic.get_ds_memory_arm9_8(adr_last_ability_id) == 58 or drastic.get_ds_memory_arm9_8(adr_last_ability_id) == 59) and (drastic.get_ds_memory_arm9_8(adr_action_id) == 85 or drastic.get_ds_memory_arm9_8(adr_action_id) == 87) and (drastic.get_ds_memory_arm9_8(adr_grounded_state) ~= 0 and drastic.get_ds_memory_arm9_8(adr_grounded_state) ~= 2) then
				downward_fireball_frames = 0
				downward_fireball_remaining = false
				--print("go")
			end
			if not downward_fireball_remaining and (drastic.get_ds_memory_arm9_8(adr_grounded_state) == 0 or drastic.get_ds_memory_arm9_8(adr_grounded_state) == 2) then
				downward_fireball_remaining = true
			end
			--fireball
			if downward_fireball_frames > -1 then
				--print(downward_fireball_frames)
				--jump
				if downward_fireball_frames > 9 and downward_fireball_frames < 29 then
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, -1)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, -1)
					if downward_fireball_frames < 13 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -5)
					elseif downward_fireball_frames < 17 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -4)
					elseif downward_fireball_frames < 21 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -3)
					elseif downward_fireball_frames < 25 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -2)
					elseif downward_fireball_frames < 29 then
						drastic.set_ds_memory_arm9_8(adr_y_vel, -1)
					end
					--print(drastic.get_ds_memory_arm9_8signed(adr_y_vel))
				elseif downward_fireball_frames == 29 then
					drastic.set_ds_memory_arm9_8(adr_y_vel, 0)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, 0)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, 0)
				end
				--fireball
				if downward_fireball_frames == 9 then
					for i=0,23,1 do
						--print(adr_final_attack_slot_attack_id - i*244 .. " " .. drastic.get_ds_memory_arm9_8(adr_final_attack_slot_attack_id - i*244))
						if drastic.get_ds_memory_arm9_8(adr_final_attack_slot_attack_id - i*244) == drastic.get_ds_memory_arm9_8(adr_last_ability_id) and drastic.get_ds_memory_arm9_8(adr_final_attack_slot_attack_id - i*244 + 3) == 0x11 then
							downward_fireball_slot = i
							--print(downward_fireball_slot)
							downward_fireball_direction = drastic.get_ds_memory_arm9_16signed(adr_final_attack_slot_direction - downward_fireball_slot*244)*2+1
							downward_fireball_start_x = drastic.get_ds_memory_arm9_32(adr_final_attack_slot_x - downward_fireball_slot*244) - downward_fireball_direction*256*30
							--print(drastic.get_ds_memory_arm9_32(adr_final_attack_slot_x - downward_fireball_slot*244))
							--print(drastic.get_ds_memory_arm9_16signed(adr_final_attack_slot_direction - downward_fireball_slot*244))
							--print(drastic.get_ds_memory_arm9_16signed(adr_final_attack_slot_direction - downward_fireball_slot*244)*(-2)-1)
							downward_fireball_start_y = drastic.get_ds_memory_arm9_32(adr_final_attack_slot_y)
							break
						end
					end
				end
				if downward_fireball_frames > 9 and downward_fireball_frames <= 60 then
					--print(drastic.get_ds_memory_arm9_32(adr_final_attack_slot_y))
					drastic.set_ds_memory_arm9_8(adr_final_attack_slot_angle - downward_fireball_slot*244, 196)
					drastic.set_ds_memory_arm9_32(adr_final_attack_slot_y - downward_fireball_slot*244, drastic.get_ds_memory_arm9_32(adr_final_attack_slot_y - downward_fireball_slot*244) + (drastic.get_ds_memory_arm9_32(adr_final_attack_slot_x - downward_fireball_slot*244) - downward_fireball_start_x)*downward_fireball_direction)
					drastic.set_ds_memory_arm9_32(adr_final_attack_slot_x - downward_fireball_slot*244, downward_fireball_start_x)
				elseif downward_fireball_frames > 60 then
					downward_fireball_frames = -2
				end
				downward_fireball_frames = downward_fireball_frames + 1
			end
			--jump

		else
			if downward_fireball_frames ~= -1 then
				downward_fireball_frames = -1
			end
			if downward_fireball_remaining == true then
				downward_fireball_remaining = false
			end
		end
	end
	return buttons
end

lx_charging = false
function lx_dragon (buttons, e, e_energy)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 5 then --if LX
			if (read_button("main") or read_button("sub")) and not lx_charging then
				lx_charging = true
			end
			if lx_charging and not (read_button("main") or read_button("sub")) and drastic.get_ds_memory_arm9_8(adr_main_charge) > quickcharge(1)-1 and (buttons & drastic.C.BUTTON_UP) ~= 0 then --if charge released at >40 and up held
				drastic.set_ds_memory_arm9_8(adr_main_charge, 120) --instant charge for dragon
				if e_energy then
					drastic.set_ds_memory_arm9_8(adr_LX_WE, drastic.get_ds_memory_arm9_8(adr_LX_WE) + 2) --refund 2 energy for dragon
				end
			end
			if not read_button("main") and not read_button("sub") and lx_charging then
				lx_charging = false
			end
		end
	end
	return buttons
end

function lx_speed_sled (e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 5 then --if LX
			if drastic.get_ds_memory_arm9_16(adr_lx_sled_1_vel) < 0 then
				drastic.set_ds_memory_arm9_16(adr_lx_sled_1_vel, -920)
			elseif drastic.get_ds_memory_arm9_16(adr_lx_sled_1_vel) > 0 then
				drastic.set_ds_memory_arm9_16(adr_lx_sled_1_vel, 920)
			end
			if drastic.get_ds_memory_arm9_16(adr_lx_sled_2_vel) < 0 then
				drastic.set_ds_memory_arm9_16(adr_lx_sled_2_vel, -920)
			elseif drastic.get_ds_memory_arm9_16(adr_lx_sled_2_vel) > 0 then
				drastic.set_ds_memory_arm9_16(adr_lx_sled_2_vel, 920)
			end
			if drastic.get_ds_memory_arm9_16(adr_lx_sled_3_vel) < 0 then
				drastic.set_ds_memory_arm9_16(adr_lx_sled_3_vel, -920)
			elseif drastic.get_ds_memory_arm9_16(adr_lx_sled_3_vel) > 0 then
				drastic.set_ds_memory_arm9_16(adr_lx_sled_3_vel, 920)
			end
		end
	end
end

lx_skullcrushing = 0
lx_skullcrush_slot = -1
function lx_skullcrush (buttons, e)
	 if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 5 then --if LX
			for i=0,23,1 do --find current slash
				if drastic.get_ds_memory_arm9_8(adr_final_attack_slot_active - i*244)%0x10 == 0xF and drastic.get_ds_memory_arm9_8(adr_final_attack_slot_attack_id - i*244) == 67 then 
					if lx_skullcrushing == 0 and drastic.get_ds_memory_arm9_8(adr_final_attack_slot_anim_frame - i*244) == 7 and (buttons & drastic.C.BUTTON_DOWN) ~= 0 and drastic.get_ds_memory_arm9_8(adr_grounded_state) == 1 then
						lx_skullcrushing = 1
						lx_skullcrush_slot = i
					end
				end
			end
			if lx_skullcrushing > 0 then
				drastic.set_ds_memory_arm9_8(adr_final_attack_slot_anim_frame - lx_skullcrush_slot*244, 7) --freeze slash frame
				drastic.set_ds_memory_arm9_8(adr_final_attack_slot_anim_frame+1 - lx_skullcrush_slot*244, 2) --fixes flashing
				if lx_skullcrushing == 1 and drastic.get_ds_memory_arm9_8(adr_anim_frame) == 7 and drastic.get_ds_memory_arm9_8(adr_anim_frame_timer) == 1 then
					lx_skullcrushing = 2
				elseif lx_skullcrushing == 2 then
					drastic.set_ds_memory_arm9_8(adr_anim_frame_timer, 2) --freeze character sprite
					drastic.set_ds_memory_arm9_32(adr_final_attack_slot_anim_frame+3 - lx_skullcrush_slot*244, 0x0218CFA0) --hitbox
				end
				if (buttons & drastic.C.BUTTON_DOWN) == 0 or drastic.get_ds_memory_arm9_8(adr_grounded_state) ~= 1 then
					lx_skullcrushing = 0
				end
			end
		elseif lx_skullcrushing ~= 0 then --just for robustness
			lx_skullcrushing = 0
		end
	 end
	return buttons
 end
 
function lx_remove_minimum_swim_distance(e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_grounded_state) == 4 then
			if drastic.get_ds_memory_arm9_8(adr_y_vel) == 1 then
				drastic.set_ds_memory_arm9_8(adr_y_vel, 0)
			end
			if memory.readbytesigned(adr_y_vel+104) == 0 then
				drastic.set_ds_memory_arm9_16(adr_y_vel, 0)
				drastic.set_ds_memory_arm9_8(adr_y_vel+2, 0)
			end
			if drastic.get_ds_memory_arm9_8(adr_x_vel) == 1 then
				drastic.set_ds_memory_arm9_8(adr_x_vel, 0)
			end
			if memory.readbytesigned(adr_x_vel+104) == 0 then
				drastic.set_ds_memory_arm9_16(adr_x_vel, 0)
				drastic.set_ds_memory_arm9_8(adr_x_vel+2, 0)
			end
		end
	end
end
swimdash_frames = -1
function lx_infinite_swimdash(e, require_overdrive)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 5 then
			if drastic.get_ds_memory_arm9_8(adr_dash_frames_remaining-1) == 20 then --if swimdashing
				if swimdash_frames == -1 then
					swimdash_frames = 27
				elseif swimdash_frames > -1 and swimdash_frames <= 27 then
					swimdash_frames = swimdash_frames - 1
				end
			else
				swimdash_frames = 0
			end
			if drastic.get_ds_memory_arm9_8(adr_dash_frames_remaining-1) == 20 and ((require_overdrive and (drastic.get_ds_memory_arm9_8(adr_overdrive) == 65 or drastic.get_ds_memory_arm9_8(adr_overdrive) == 67) or not require_overdrive)) then
				drastic.set_ds_memory_arm9_8(adr_dash_frames_remaining, 30)
			else
				drastic.set_ds_memory_arm9_8(adr_dash_frames_remaining, swimdash_frames)
			end
		end
	end
end
continuous_overdrive = false
function hx_infinite_airdash(e, require_overdrive)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 3 then
			if drastic.get_ds_memory_arm9_8(adr_grounded_state) == 1 and ((require_overdrive and (drastic.get_ds_memory_arm9_8(adr_overdrive) == 65 or drastic.get_ds_memory_arm9_8(adr_overdrive) == 67) or not require_overdrive)) and continuous_overdrive == false then
				continuous_overdrive = true
			elseif continuous_overdrive == true and (drastic.get_ds_memory_arm9_8(adr_grounded_state) == 1 or ((require_overdrive and (drastic.get_ds_memory_arm9_8(adr_overdrive) == 65 or drastic.get_ds_memory_arm9_8(adr_overdrive) == 67) or not require_overdrive))) then 
				continuous_overdrive = false --false if you land or if overdrive is disabled at any point in the air
			end
			if drastic.get_ds_memory_arm9_8(adr_grounded_state) == 1 and ((require_overdrive and (drastic.get_ds_memory_arm9_8(adr_overdrive) == 65 or drastic.get_ds_memory_arm9_8(adr_overdrive) == 67) or not require_overdrive)) and drastic.get_ds_memory_arm9_8(adr_dash_frames_remaining) == 2 then
				drastic.set_ds_memory_arm9_8(adr_dash_frames_remaining, 3)
			end
			if continuous_overdrive and drastic.get_ds_memory_arm9_8(adr_dash_frames_remaining-1) == 4 then
				drastic.set_ds_memory_arm9_8(adr_dash_frames_remaining-1, 0)
			end
		end
	end
end

highjump_frame_count = -1
b_initial_press = 0 --0=not pressed, 1=initial press frame, 2=held down
function px_highjump (buttons, e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 6 then
			if b_initial_press > 0 and not read_button("jump") then
				b_initial_press = 0
			end
			if b_initial_press == 0 and read_button("jump") then
				b_initial_press = 1
			end
			if drastic.get_ds_memory_arm9_8(adr_PX_WE) > 0 and drastic.get_ds_memory_arm9_8(adr_grounded_state) == 0 and b_initial_press == 1 and (buttons & drastic.C.BUTTON_UP) ~= 0 and not (buttons & drastic.C.BUTTON_LEFT) ~= 0 and not (buttons & drastic.C.BUTTON_RIGHT) ~= 0 then
				highjump_frame_count = 0
				drastic.set_ds_memory_arm9_8(adr_PX_WE, drastic.get_ds_memory_arm9_8(adr_PX_WE) - 1 ) --spend 1 energy
			end
			if highjump_frame_count > -1 then
				if highjump_frame_count < 16 then
					drastic.set_ds_memory_arm9_8(adr_y_vel, -8)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, -1)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, -1)
					highjump_frame_count = highjump_frame_count + 1
				else
					highjump_frame_count = -1
					drastic.set_ds_memory_arm9_8(adr_y_vel, 0)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_1, 0)
					drastic.set_ds_memory_arm9_8(adr_y_vel_something_2, 0)
				end
			end
			if b_initial_press == 1 then
				b_initial_press = 2
			end
		else
			if highjump_frame_count > -1 then
				highjump_frame_count = -1
			end
			if b_initial_press > 0 then
				b_initial_press = 0
			end
		end
	end
	return buttons
end

--i'm not sure why this either causes slowdowns or doesn't work so i wrote another function for it (below this one)
function px_kunai_spread_control_old (buttons, e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 6 then
			if drastic.get_ds_memory_arm9_32(adr_px_kunai_angles) == 807407616 then
				if read_button("sub") then
					drastic.set_ds_memory_arm9_32(adr_px_kunai_angles, 0)
				end
			elseif drastic.get_ds_memory_arm9_32(adr_px_kunai_angles) == 0 then
				if read_button("main") then
					drastic.set_ds_memory_arm9_32(adr_px_kunai_angles, 807407616)
				end
			end
		end
	end
	return buttons
end
--alternate function to hopefully stop slowdowns
kunai_r_frames = -1
kunai_y_frames = -1
function px_kunai_spread_control (buttons, e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 6 then
			if read_button("sub") then
				if kunai_r_frames < 3 then
					kunai_r_frames = kunai_r_frames + 1
				end
			elseif kunai_r_frames > -1 then
				kunai_r_frames = -1
			end
			if read_button("main") then
				if kunai_y_frames < 3 then
					kunai_y_frames = kunai_y_frames + 1
				end
			elseif kunai_y_frames > -1 then
				kunai_y_frames = -1
			end
			if drastic.get_ds_memory_arm9_8(adr_px_num_kunai_in_last) == 0 then
				if kunai_r_frames > -1 and kunai_r_frames < 3 then
					drastic.set_ds_memory_arm9_32(adr_px_kunai_angles, 0)
					kunai_r_frames = 3 --so that this only happens for 1 frame
				elseif kunai_y_frames > -1 and kunai_y_frames < 3 then
					drastic.set_ds_memory_arm9_32(adr_px_kunai_angles, 807407616)
					kunai_y_frames = 3
				end
			end
		end
	end
	return buttons
end

groundbreaker_count = -1
function fx_groundbreaker_multihit (e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 4 then
			if groundbreaker_count > -1 and groundbreaker_count < 8 then
				groundbreaker_count = groundbreaker_count + 1
			elseif groundbreaker_count >= 8 then
				groundbreaker_count = -1
			end
			if drastic.get_ds_memory_arm9_8(adr_priority) == 32 and groundbreaker_count == -1 then
				drastic.set_ds_memory_arm9_8(adr_priority, 31)
				groundbreaker_count = 0
			end
		end
	end
end

fx_charging_left = false
fx_charging_right = false
function fx_groundbreaker_quickcharge (buttons, e)
	if e then
		if drastic.get_ds_memory_arm9_8(adr_model) == 4 then
			if read_button("main") and not fx_charging_left then
				fx_charging_left = true
			end
			if read_button("sub") and not fx_charging_right then
				fx_charging_right = true
			end
			if fx_charging_left and not read_button("main") and drastic.get_ds_memory_arm9_8(adr_main_charge) > quickcharge(1) and (buttons & drastic.C.BUTTON_DOWN) ~= 0 then --if charge released at >40 and down held
				drastic.set_ds_memory_arm9_8(adr_main_charge, 120) --instant charge for groundbreaker
				--drastic.set_ds_memory_arm9_8(adr_FX_WE, drastic.get_ds_memory_arm9_8(adr_FX_WE) + 2) --refund 2 energy for groundbreaker
			end
			if fx_charging_right and not read_button("sub") and drastic.get_ds_memory_arm9_8(adr_sub_charge) > quickcharge(1) and (buttons & drastic.C.BUTTON_DOWN) ~= 0 then --if charge released at >40 and down held
				drastic.set_ds_memory_arm9_8(adr_sub_charge, 120) --instant charge for groundbreaker
				--drastic.set_ds_memory_arm9_8(adr_FX_WE, drastic.get_ds_memory_arm9_8(adr_FX_WE) + 2) --refund 2 energy for groundbreaker
			end
		end
	end
	return buttons
end

pal_x_armor = {{0x06D6018E, 0x63FF1FDE},
			   {0x00390010, 0x5F1F1D1F},
			   {0x6E4A4944, 0x7FDC7F53}}
--pal_x_green = {0x16E10DA0, 0x6BF82BC8}
--pal_x_lavender = {0x69F14509, 0x7FDE7ED7}

pal_chargeshot = {{0x7BDE, 0x7FF9, 0x5F85, 0x52C0, false, 0x5FFF, 0x3BF6, 0x3F80, 0x7F20, 0x6240, 0x3EDF, 0x51DF},
				  {false, 0x33DC, 0x1FAF, false, false, 0x43FF, false, false, 0x3360, 0x36A0, 0x13FF, 0x03BD},
				  {false, 0x2B7F, 0x1A1F, false, false, 0x37FF, false, false, 0x111E, 0x0018, 0x273F, 0x1E5F},
				  {false, 0x7FF9, 0x7FB3, false, false, 0x7FF9, false, false, 0x7F25, 0x6E20, 0x7F4F, 0x6ECA}}

adr_chargeshot_palettes = {0x021CF982, 0x021CFF32, 0x021D0492, 0x021D09F2, 0x021D0F52}

a_pressed_status = 0
element_equipped = 0 --0 none, 1 elec, 2 fire, 3 ice
function element_switch (buttons, x, z)
	if (x and drastic.get_ds_memory_arm9_8(adr_definite_model) == 1) or (z and drastic.get_ds_memory_arm9_8(adr_definite_model) == 2) then --X/ZX
		--record default chargeshot colors
		--[[
		for i=1,13,1 do
			pal_chargeshot[1][i] = drastic.get_ds_memory_arm9_16(adr_chargeshot_palettes[1]+(i-1)*2)
		end
		]]
		--A instant press status (to avoid switching every frame while pressed)
		if read_button("overdrive") and a_pressed_status == 0 then
			a_pressed_status = 1
		elseif read_button("overdrive") and a_pressed_status == 1 then
			a_pressed_status = 2
		elseif not read_button("overdrive") then
			a_pressed_status = 0
		end
		--Switch element
		if a_pressed_status == 1 then
			if element_equipped < 3 then
				element_equipped = element_equipped + 1
			else
				element_equipped = 0
			end
		end
		--Use element if attack used
		if drastic.get_ds_memory_arm9_8(adr_priority) == 3 or drastic.get_ds_memory_arm9_8(adr_priority) == 224 then --priority of blue shot with pink orbits or charge saber
			drastic.set_ds_memory_arm9_8(0x02150C9F, element_equipped * 16) -- set element
		end
		if element_equipped == 0 then
			--gui.text(6,-94, "N")
			--reset armor colors
			if drastic.get_ds_memory_arm9_32(adr_current_model_palette + 10) ~= 0x7FFF7B7A then
				for i=1,15,1 do
					drastic.set_ds_memory_arm9_16(adr_current_model_palette + (i-1)*2, drastic.get_ds_memory_arm9_16(adr_x_palette + (i-1)*2))
				end
			end
			--reset fake overdrive
			if drastic.get_ds_memory_arm9_8(adr_overdrive) == 67 then 
				drastic.set_ds_memory_arm9_8(adr_overdrive, 66)
			end
		else --if element
			--set palette
			if drastic.get_ds_memory_arm9_32(adr_current_model_palette + 10) ~= pal_x_armor[element_equipped][1] then
				drastic.set_ds_memory_arm9_32(adr_current_model_palette + 10, pal_x_armor[element_equipped][1])
				drastic.set_ds_memory_arm9_32(adr_current_model_palette + 14, pal_x_armor[element_equipped][2])
			end
			--apply fake overdrive
			if drastic.get_ds_memory_arm9_8(adr_overdrive) == 64 or drastic.get_ds_memory_arm9_8(adr_overdrive) == 66 then 
				drastic.set_ds_memory_arm9_8(adr_overdrive, 67)
			end
			--element doesnt get first shot of doubleshot, for balance :) need to find way to let you release button to shoot it though :(
			--[[
			if drastic.get_ds_memory_arm9_16(adr_main_charge) == 0x6060 then
				drastic.set_ds_memory_arm9_16(adr_main_charge, 0x6000) 
			end
			]]
			--find fired charge shots
			for i=0,23,1 do
				if drastic.get_ds_memory_arm9_8(adr_final_attack_slot_active - i*244)%0x10 == 0xF then 
					if drastic.get_ds_memory_arm9_8(adr_final_attack_slot_attack_id-1 - i*244) >= 2 then
						drastic.set_ds_memory_arm9_8(adr_final_attack_slot_overdrive - i*244, 0x0F)
						drastic.set_ds_memory_arm9_8(adr_final_attack_slot_overdrive+1 - i*244, 0x0A)
						drastic.set_ds_memory_arm9_8(adr_final_attack_slot_element - i*244, element_equipped)
						drastic.set_ds_memory_arm9_8(adr_final_attack_slot_element - i*244+1, 0x02)
					else
						drastic.set_ds_memory_arm9_8(adr_final_attack_slot_element - i*244, 0) --remove element from slot when using other attacks
					end
				end
			end
		end
		--change charge shot color
		if drastic.get_ds_memory_arm9_16(adr_chargeshot_palettes[1] + 2) ~= pal_chargeshot[element_equipped+1][2] then
			for i,x in ipairs(adr_chargeshot_palettes) do
				for j,y in ipairs(pal_chargeshot[element_equipped+1]) do
					if y then
						drastic.set_ds_memory_arm9_16(x+(j-1)*2, y)
					end
				end
			end
		end
	end
	return buttons
end
--todo:
--script to determine slots containing charge shot
--script to apply colors (all 5 palettes; check out main though?)
-- how to make elemental:
-- -apply overdrive
-- -set attack overdrive value to 0F
-- -set element
-- ?-set element+1 to 01



--- Aesthetic changes (enable in main function below) ---

if not jp then
	adr_dash_pal_start = 0x020F5C6A
elseif jp then
	adr_dash_pal_start = 0x020F79EA
end
dash_count = 26
dash_color = 6175 --red 6 steps backwards toward magenta
dash_delta = -1024
function rainbow_dash(e)
	if e then
		for i=0,14,1 do
			drastic.set_ds_memory_arm9_16(adr_dash_pal_start + i*2, dash_color)
		end
		
		dash_color = dash_color + dash_delta
		
		if dash_count < 31 then
			dash_count = dash_count + 1
		else
			dash_count = 1
			if dash_delta == 32 then
				dash_delta = -1
			elseif dash_delta == -1 then
				dash_delta = 1024
			elseif dash_delta == 1024 then
				dash_delta = -32
			elseif dash_delta == -32 then
				dash_delta = 1
			elseif dash_delta == 1 then
				dash_delta = -1024
			elseif dash_delta == -1024 then
				dash_delta = 32
			end
		end
	end
end

function spinspinspin (e)
	if e then
		for i=0,19,1 do
			rando = math.random(0,255)
			drastic.set_ds_memory_arm9_8(adr_final_attack_slot_angle - i*244, rando)
		end
	end
end

function select_change_model(buttons, e)
	if e then
		if (buttons & drastic.C.BUTTON_SELECT) ~= 0 then
			if (buttons & drastic.C.BUTTON_UP) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 1)
			elseif (buttons & drastic.C.BUTTON_DOWN) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 2)
			elseif (buttons & drastic.C.BUTTON_LEFT) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 3)
			elseif (buttons & drastic.C.BUTTON_RIGHT) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 4)
			elseif (buttons & drastic.C.BUTTON_L) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 5)
			elseif (buttons & drastic.C.BUTTON_R) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 6)
			elseif (buttons & drastic.C.BUTTON_A) ~= 0 then
				drastic.set_ds_memory_arm9_8(0x0214FC74, 7)
			end
		end
	end
	return buttons
end

--Feel free to change these to enable/disable entire categories of functions rather than individual ones
functional = true
cosmetic = true
actionreplay_functions = true
--MAIN
read_controls()
while true do
	if drastic.get_ds_memory_arm9_8(adr_pause_menu_page) == 2 then
		read_controls()
	end
	local buttons = drastic.get_buttons()
	if functional then 
		autofill_energy(true) --Autofill 1 energy to all models every 3 seconds
		buttons = double_jump(buttons, true, true, true) --Gives double jump to OX, ZX, X (set booleans to toggle for each)
		--double jump arguments: (enable ox, enable zx, enable x, enable dashjump-jump ox, enable dashjump-jump zx, enable dashjump-jump x)!NOT IMPLEMENTED! 
		buttons = fx_ground_breaker_jump(buttons, true) --Hold B as FX while using ground breaker to do a recoil rod-style super jump
		buttons = fx_aerial_punch_jump(buttons, true) --Can shoot fireball downward in the air for a vertical boost
		buttons = lx_dragon(buttons, true, true) --Reduces the charge time and energy cost of ice dragon
		--lx dragon arguments: (enable lv1 charge, enable reduced energy)
		lx_speed_sled(true) --0 acceleration time for sled
		buttons = lx_skullcrush(buttons, true)
		lx_infinite_swimdash(true, true) 
		--lx infinite swimdash arguments: (enable, require overdrive)
		hx_infinite_airdash(true, true) 
		--hx infinite airdash arguments: (enable, require overdrive)
		buttons = px_highjump(buttons, true) --Hold up as PX and press B to do a MMX6 Shadow Armor-style highjump
		buttons = px_kunai_spread_control(buttons, true) --Press R as PX to throw kunai straight forward, press Y for classic spread
		fx_groundbreaker_multihit(true)
		buttons = fx_groundbreaker_quickcharge(buttons, true)
		buttons = element_switch(buttons, false) --Press Overdrive button to switch between elements applied to X's charge attacks (like MMZ chips)
	end
	if cosmetic then
		rainbow_dash(true) --a shifting rainbow trail
		spinspinspin(false) --unleash the beyblade
	end
	
	if actionreplay_functions then
		select_change_model(buttons, true)
	end
	
	drastic.set_buttons(buttons)
end
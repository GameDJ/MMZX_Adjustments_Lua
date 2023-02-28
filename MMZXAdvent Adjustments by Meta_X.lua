--Mega Man ZX Advent adjustments v0.2.1 by Meta_X
--Should work for both the JP and EN versions as well as the undub
--Scroll to the bottom and change values to "false" to toggle off specific functions
--Note: Default controls are assumed, as well as default buster/saber for ZX
--Changes:
--All: Quick Charge (toggleable per model)
--ZX: Access to both ex skills
--    Triple slash endlag can be canceled into rising fang by pressing up, somewhat like in Z3/4 and ZX
--H: Access to both charge skills
--   -Ashe (straight) tornadoes lv1, Grey (curved) tornadoes lv2+up
--L: Access to both charge skills
--   -Ice Ball lv1, Ice Dragon lv2+up
--   Ice Ball costs 2 energy instead of 4
--P: Access to both charge skills
--   -Shuriken lv1, Mandala stars lv2+up
--   Press R to throw kunai straight ahead, Y for default angles
--   Mandala stars don't trigger iframes (only vs single bosses for now)
--   Shadowdash: Press A to toggle on invincible dashing. Energy is only consumed while dashing
--
-- !!!!!!!!!!!!
--Please use this script with caution. Certain unaccounted actions like canceling modded moves into other things, mashing, etc will likely result in issues so try not to mess around with that. Save frequently in case of crashing or other major errors
-- !!!!!!!!!!!!


--Hopefully this is consistent for determining game version :P
if memory.readword(0x0200000E) == 0xB9FF then
	version = 0
	print("jp")
elseif memory.readword(0x02000B7C) == 0x0000 then
	version = 1
	print("undub")
elseif memory.readword(0x02000B7C) == 0x81C4 then
	version = 2
	print("en")
else
	version = 2
	print("en?")
end

--all versions
adr_pal_weapon_energy = 0x022328D8
if version == 0 then --jp
	adr_model = 0x02168B60
	adr_character = 0x02168B61
	adr_model_post = 0x0211391C
	adr_charge = 0x02168B14
	adr_weapon_energy = 0x02168B94 --guessed
	adr_weapon_energy_max = 0x02169751 --guessed --READONLY --divided by 4
	adr_kunai_angle_aerial = 0x021B81FC
	adr_kunai_angle_ground = 0x021B8200
	adr_attack_id = 0x02168B24
	adr_attack_frame = 0x02168A2B
	adr_iframes = 0x02168A80 --guessed
	adr_dash_frames = 0x02168B0C --guessed
	adr_animation = 0x02168A54 --guessed
	adr_boss_iframes = 0x02169108
	adr_double_boss_1_iframes = 0x02168EF0
	adr_double_boss_1_iframes = 0x02168FFC
	adr_boss_priority = 0x0216910A
	adr_boss_hp = 0x02169116
	adr_double_boss_1_hp = 0x02168EFE --guessed
	adr_double_boss_2_hp = 0x0216900A --guessed
	adr_input_1 = 0x0210BEEC
	adr_input_2 = 0x0210BEED
	adr_currently_attacking = 0x02168B02
	adr_menu = 0x0210D570
elseif version >= 1 then --undub or en
	adr_model = 0x02169DEC --use for writing (when read is affected by the model wheel)
	adr_character = 0x02169DED
	adr_model_post = 0x02113730 --use for reading
	adr_charge = 0x02169DA0
	adr_weapon_energy = 0x02169E20
	adr_weapon_energy_max = 0x0216A9DD --READONLY --divided by 4
	adr_kunai_angle_aerial = 0x021B7FFC
	adr_kunai_angle_ground = 0x021B8000
	adr_attack_id = 0x02169DB0
	adr_attack_frame = 0x02169CB7 
	adr_iframes = 0x02169D0C
	adr_dash_frames = 0x02169D98
	adr_animation = 0x02169CE0
	adr_boss_iframes = 0x0216A394
	adr_double_boss_1_iframes = 0x0216A17C
	adr_double_boss_2_iframes = 0x0216A288
	adr_boss_priority = 0x0216A396
	adr_boss_hp = 0x0216A3A2
	adr_double_boss_1_hp = 0x0216A18A
	adr_double_boss_2_hp = 0x0216A296
	adr_input_1 = 0x02110CB0 --includes dpad, AB, Select/Start
	adr_input_2 = 0x02110CB1 --includes X/Y and shoulders
	adr_currently_attacking = 0x02169D8E --typically 3 = attacking, 1 = not
	--0x02178f2a, was hoping it would fix early megamen but didnt
	adr_menu = 0x0210D384 --extremely sus... but seems like typically 128 if menu or 65535 if talking
elseif version == 1 then --undub only
else --en only (version == 2)
end

function quick_charge (eA, eZ, eH, eF, eL, eP)
	if (eA == true and memory.readbyte(adr_model_post) == 8) or (eZ == true and memory.readbyte(adr_model_post) == 2) or (eH == true and memory.readbyte(adr_model_post) == 3) or (eF == true and memory.readbyte(adr_model_post) == 4) or (eL == true and memory.readbyte(adr_model_post) == 5) or (eP == true and memory.readbyte(adr_model_post) == 6) then
		if memory.readbyte(adr_charge) == 32 then
			memory.writebyte(adr_charge, 40)
		end
		if memory.readbyte(adr_charge) > 96 and memory.readbyte(adr_charge) < 120 then
			memory.writebyte(adr_charge, 120)
		end
		if memory.readbyte(adr_charge+1) == 32 then
			memory.writebyte(adr_charge+1, 40)
		end
		if memory.readbyte(adr_charge+1) > 96 and memory.readbyte(adr_charge+1) < 120 then
			memory.writebyte(adr_charge+1, 120)
		end
	end
end

--use both Ashe and Grey's charge attacks as either character
character_changed_count = -1
function both_charges (eH, eL, eP)
	if (eH == true and memory.readbyte(adr_model_post) == 3) or (eL == true and memory.readbyte(adr_model_post) == 5) or (eP == true and memory.readbyte(adr_model_post) == 6) then
		--if charged and button is released then switch character for a frame
		if memory.readbyte(adr_charge) == 120 and joypad.get(1).up and not (joypad.get(1).Y or joypad.get(1).R) then --shield
			memory.writebyte(adr_charge, 120)
			character = memory.readbyte(adr_character) --remember character
			if memory.readbyte(adr_model_post) == 6 then
				memory.writebyte(adr_character, 1) --P uses ashe for lv2
			else
				memory.writebyte(adr_character, 0) --H/L use grey for lv2
			end
			character_changed_count = 0 --start changed character count
		elseif memory.readbyte(adr_charge) > 39 and (memory.readbyte(adr_charge) < 120 or not joypad.get(1).up) and not (joypad.get(1).Y or joypad.get(1).R) then --shuriken
			memory.writebyte(adr_charge, 120)
			if memory.readbyte(adr_model_post) == 5 then
				memory.writebyte(adr_weapon_energy, memory.readbyte(adr_weapon_energy)+2)
			end
			character = memory.readbyte(adr_character)
			if memory.readbyte(adr_model_post) == 6 then
				memory.writebyte(adr_character, 0) --P uses ashe for lv1
			else
				memory.writebyte(adr_character, 1) --H/L use grey for lv1
			end
			character_changed_count = 0
		end
		if memory.readbyte(adr_model_post) == 3 then --if H uses subcharge
			if memory.readbyte(adr_charge+1) == 120 and joypad.get(1).up and not (joypad.get(1).Y or joypad.get(1).R) then --shield
				memory.writebyte(adr_charge+1, 120)
				character = memory.readbyte(adr_character) --remember character
				if memory.readbyte(adr_model_post) == 6 then
					memory.writebyte(adr_character, 1) --P uses ashe for lv2
				else
					memory.writebyte(adr_character, 0) --H/L use grey for lv2
				end
				character_changed_count = 0 --start changed character count
			elseif memory.readbyte(adr_charge+1) > 39 and (memory.readbyte(adr_charge+1) < 120 or not joypad.get(1).up) and not (joypad.get(1).Y or joypad.get(1).R) then --shuriken
				memory.writebyte(adr_charge+1, 120)
				character = memory.readbyte(adr_character)
				if memory.readbyte(adr_model_post) == 6 then
					memory.writebyte(adr_character, 0) --P uses ashe for lv1
				else
					memory.writebyte(adr_character, 1) --H/L use grey for lv1
				end
				character_changed_count = 0
			end
		end
		if character_changed_count > -1 then
			if character_changed_count < 7 then --switch char back after a few frames
				character_changed_count = character_changed_count + 1
			else
				memory.writebyte(adr_character, character)
				character_changed_count = -1
			end
		else
			if not memory.readbyte(adr_character) == character then
				memory.writebyte(adr_character, character)
			end
		end
	end
end


---------------------------------- ZX buffs --------------------------------------

--Buffs for Model ZX in Mega Man ZX Advent (EN) by Meta_X, v0.1.2
--Buffs to the move properties not part of script, see action replay code at the bottom
--Changes:
--Allows Grey/Aile to use Rising Fang and Ashe/Vent to use Fission
--Allows triple slash cancel into Rising Fang (press up during the third slash)
--NOTE: currently meant to be used with Y for saber and B for jump (change in the code if you use something different)
triple_cancel = false
triple_cancel_frames = -1
raw_character_switch_frames = -1
function zx_changes (e)
	if e and memory.readbyte(adr_model_post) == 2 then
		--if model zx, and third slash of triple, and late enough frame
		if memory.readbyte(adr_model_post) == 2 and memory.readbyte(adr_attack_id) == 51 and triple_cancel_frames == -1 then
			if joypad.get(1).up and not triple_cancel then
				triple_cancel = true
			end
			if triple_cancel then
				joy = {}
				joy["A"] = false --forces you into the uppercut
				joy["B"] = false --no shenanigans >:(
				joy["X"] = false
				joy["L"] = false
				joy["R"] = false
				joypad.set(1, joy)
				--cancel into triple slash starting at this frame
				if memory.readbyte(adr_attack_frame) >= 89 then
					triple_cancel_frames = 0
				end
			end
		end
		if triple_cancel_frames == 0 then
			memory.writebyte(adr_currently_attacking, 1) --force cancel
			memory.writebyte(adr_input_1, 0) --subdue up press
			memory.writebyte(adr_input_2, 0) --subdue Y press
			character = memory.readbyte(adr_character) --record character
			triple_cancel_frames = 1
		elseif triple_cancel_frames > 0 then
			if triple_cancel_frames == 1 then
				memory.writebyte(adr_currently_attacking, 1) --force cancel still
			end
			if triple_cancel_frames < 7 then
				memory.writebyte(adr_character, 1) --force into ashe (vent)
				joy = {}
				joy["A"] = false --forces you into the uppercut
				joy["B"] = false --no shenanigans >:(
				joy["X"] = false
				joy["L"] = false
				joy["R"] = false
				joy["Y"] = true
				joy["up"] = true
				joypad.set(1, joy)
				triple_cancel_frames = triple_cancel_frames + 1
			elseif triple_cancel_frames == 7 then
				triple_cancel_frames = -1
				memory.writebyte(adr_character, character) --return to original character
				triple_cancel = false
			end
		end
		--print(triple_cancel_frames)
		
		--Allow Grey/Aile to use Rising Fang
		--If Grey, and not doing anything else, and pressing up + Y
		if memory.readbyte(adr_character) == 0 and (memory.readbyte(adr_attack_id) == 0 or memory.readbyte(adr_attack_id) == 4 or memory.readbyte(adr_attack_id) == 7) and joypad.get(1).up and joypad.get(1).Y then
			character = memory.readbyte(adr_character)
			memory.writebyte(adr_character, 1) --force into ashe (vent)
			raw_character_switch_frames = 0 --switchback handled below
		end
		--Allow Ashe/Vent to use Fission
		--If Ashe, and [one of various air states], and pressing down + Y
		if memory.readbyte(adr_character) == 1 and ((memory.readbyte(adr_attack_id) == 5 or memory.readbyte(adr_attack_id) == 6 or memory.readbyte(adr_attack_id) == 9 or memory.readbyte(adr_attack_id) == 10) or ((memory.readbyte(adr_attack_id) == 0 or memory.readbyte(adr_attack_id) == 7 or memory.readbyte(adr_attack_id) == 2 or memory.readbyte(adr_attack_id) == 3 or memory.readbyte(adr_attack_id) == 4) and joypad.get(1).B)) and joypad.get(1).down and joypad.get(1).Y then
			character = memory.readbyte(adr_character)
			memory.writebyte(adr_character, 0) --force into grey (aile)
			raw_character_switch_frames = 0 --switchback handled below
		end
		--Switch back
		if raw_character_switch_frames == 0 then
			raw_character_switch_frames = 1
		elseif raw_character_switch_frames == 1 then
			memory.writebyte(adr_character, character) --return to original character
			raw_character_switch_frames = -1
		end

		--attempt to cancel post fang state...
		--if memory.readbyte(adr_attack_id) == 88 then
			--memory.writebyte(, 6)
		--end
	end
end
--[[
Rising Fang/Fission buffs (Action Replay code)
Changes:
-Increased fang's wave priority so it combos from the saber
-Increased fission saber damage to 10
-Increased fission priority so it can be combo'd after rising fang
-Increased rocks priority so they can be combod after the saber part
-Gave fission better hitboxes to match the sprites
221B97F3 000000DA
221B9823 000000DA
221B9463 000000DC
221B94C3 000000DD
221B945F 0000000A
221B94BF 00000005
92169DB0 00000059
921B9472 00003400
92169CB6 0000BC18
221B9471 0000000E
221B9473 0000001C
221B946D 000000F4
221B946F 000000FB
D0000000 00000000
D0000000 00000000
921B9472 00003C00
92169CB6 0000BB18
221B9471 0000001A
221B9473 00000034
221B946D 000000EE
221B946F 000000EF
D2000000 00000000
A2169DB0 00000059
221B9471 0000001A
221B9473 0000003C
221B946D 000000EE
221B946F 000000EB
D2000000 00000000
]]
	
---------------------------------- P buffs --------------------------------------

function p_kunai_spread_control (e)
	if e then
		if memory.readbyte(adr_model_post) == 6 then
			if memory.readdword(adr_kunai_angle_aerial) == 0x301C08F4 or memory.readdword(adr_kunai_angle_ground) == 0x01FEFBF8 then
				if joypad.get(1).R then
					memory.writedword(adr_kunai_angle_aerial, 0) --aerial angle
					memory.writedword(adr_kunai_angle_ground, 0) --grounded angle
				end
			elseif memory.readdword(adr_kunai_angle_aerial) == 0 or memory.readdword(adr_kunai_angle_ground) == 0 then
				if joypad.get(1).Y then
					memory.writedword(adr_kunai_angle_aerial, 0x301C08F4)
					memory.writedword(adr_kunai_angle_ground, 0x01FEFBF8)
				end
			end
		end
	end
end

boss_last_hp = 64
boss_1_last_hp = 48
boss_2_last_hp = 48
in_boss_fight = false
function p_mandala_no_iframes (e) 
	if e then
		if memory.readbyte(adr_model_post) == 6 then
			if memory.readbyte(adr_boss_hp) > 0 and not in_boss_fight then
				in_boss_fight = true --starting boss fight
			elseif in_boss_fight and memory.readbyte(adr_boss_hp) == 0 then
				in_boss_fight = false --ended boss fight
			end
			
			if memory.readbyte(adr_boss_hp) > 0 then --single boss
				if (boss_last_hp - memory.readbyte(adr_boss_hp)) == 3 or (boss_last_hp - memory.readbyte(adr_boss_hp)) == 4 then --if dealt 3 damage (shield) or 4 from hitting weakspot
					memory.writebyte(adr_boss_iframes, 0) --set boss iframes to 0
				end
				if in_boss_fight then --remember boss's hp of this frame
					boss_last_hp = memory.readbyte(adr_boss_hp)
				end
			end
			if memory.readbyte(adr_double_boss_1_hp) > 0 or memory.readbyte(adr_double_boss_2_hp) > 0 then --2 bosses
				if (boss_1_last_hp - memory.readbyte(adr_double_boss_1_hp)) == 3 or (boss_1_last_hp - memory.readbyte(adr_double_boss_1_hp)) == 4 then --if dealt 3 damage (shield) or 4 from hitting weakspot
					memory.writebyte(adr_double_boss_1_iframes, 0) --set boss iframes to 0
				end
				if (boss_2_last_hp - memory.readbyte(adr_double_boss_2_hp)) == 3 or (boss_2_last_hp - memory.readbyte(adr_double_boss_2_hp)) == 4 then --if dealt 3 damage (shield) or 4 from hitting weakspot
					memory.writebyte(adr_double_boss_2_iframes, 0) --set boss iframes to 0
				end
				if in_boss_fight then --remember boss's hp of this frame
					boss_1_last_hp = memory.readbyte(adr_double_boss_1_hp)
				end
				if in_boss_fight then --remember boss's hp of this frame
					boss_2_last_hp = memory.readbyte(adr_double_boss_2_hp)
				end
			end
		end
	end
end

dashing = false
pal_weapon_energy = 0x23EE31C7
iframes = 0
shadowdash_toggled = false
shadowdash_toggle_press_state = -1
last_dash_frames = 28
function p_shadowdash(e)
	if e then
		if memory.readbyte(adr_model_post) == 6 then
			if memory.readword(adr_menu) ~= 128 and memory.readword(adr_menu) ~= 65535 then
				if joypad.get(1).A then
					if shadowdash_toggle_press_state == -1 then
						if not shadowdash_toggled then
							pal_weapon_energy = memory.readdword(adr_pal_weapon_energy) --save current WE color
							shadowdash_toggled = true
						else
							memory.writedword(adr_pal_weapon_energy, pal_weapon_energy) --turns WE color back to normal
							shadowdash_toggled = false
						end
						shadowdash_toggle_press_state = 0
					elseif shadowdash_toggle_press_state == 0 then
						shadowdash_toggle_press_state = 1
					end
				elseif not joypad.get(1).A and shadowdash_toggle_press_state > -1 then
					shadowdash_toggle_press_state = -1
				end
			end
			if shadowdash_toggled then
				memory.writedword(adr_pal_weapon_energy, 0x67393DEF) --turns weapon energy gray
				if memory.readbyte(adr_animation) == 6 and memory.readbyte(adr_weapon_energy) > 0 then
					if dashing == false then
						iframes = memory.readbyte(adr_iframes) --save iframes so we dont cut them off
						dashing = true
					end
					memory.writebyte(adr_iframes, 3) --should give iframes and white flash
					if (memory.readbyte(adr_dash_frames) == 26 or memory.readbyte(adr_dash_frames) == 13) and memory.readbyte(adr_dash_frames) < last_dash_frames then
						memory.writebyte(adr_weapon_energy, memory.readbyte(adr_weapon_energy)-1)
					end
					last_dash_frames = memory.readbyte(adr_dash_frames)
				elseif dashing == true then
					memory.writebyte(adr_iframes, iframes/2) --restore paused iframes but halve them to reduce holding them
					iframes = 0
					dashing = false
				end
			end
		end
	end
end


while true do
	quick_charge(true, true, true, true, true, true)
	--enable for (A, ZX, H, F, L, P)
	both_charges(true, true, true)
	--enable for (H, L, P)
	
	zx_changes(true)

	p_kunai_spread_control(true)
	p_mandala_no_iframes(true)
	p_shadowdash(true)

	emu.frameadvance()
end
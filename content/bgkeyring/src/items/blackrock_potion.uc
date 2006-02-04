/*
 *	This source file contains the usecode for the Blackrock potion.
 *
 *	Author: Marzo Junior
 *	Last Modified: 2001-02-03
 */

killTargetNPC ()
{
	var npcshape;
	var npclist;
	var npc;
	var pos;
	var body;
	var scroll;
	var alignment;
	var ownedscrolls;
	var scrollquality;
	
	npcshape = get_item_shape();
	if (npcshape == SHAPE_LORD_BRITISH)
	{
		//The victim is the King of Britannia
		//Make all friendly NPCs around hostile and attack Avatar:
		npclist = AVATAR->find_nearby(-1, 80, MASK_NPC2);
		for (npc in npclist with index to count)
		{
			npcshape = npc->get_item_shape();
			if (!((npcshape == SHAPE_MALE_AVATAR) || (npcshape == SHAPE_FEMALE_AVATAR)))
			{
				if (npc->get_alignment() == 0)
				{
					npc->set_alignment(2);
					npc->set_schedule_type(IN_COMBAT);
				}
			}
		}
		//Kill Lord British:
		pos = get_object_position();
		//Create LB's body (the bastard cannot be killed...):
		body = UI_create_new_object(SHAPE_BODIES_2);
		body->set_item_frame_rot(get_item_frame_rot());
		body->set_item_frame(FRAME_LBBODY2);
		//Remove LB:
		LORD_BRITISH->remove_npc();
		//Place the body in LB's old position:
		UI_update_last_created(pos);
		//Create LB's will:
		scroll = UI_create_new_object(SHAPE_SCROLL);
		scroll->set_item_frame(0);
		scroll->set_item_quality(43);
		body->give_last_created();
		//Dying sequence:
		script body
		{
			wait 5;
			frame CAST_2_SOUTH;
			wait 2;
			frame KNEEL_NORTH;
		}
	}
	else
	{
		//Get the NPC's alignment:
		alignment = get_alignment();
		if (!get_item_flag(TEMPORARY))
		{
			//Permanent NPCs work differently;
			//kill NPC:
			kill_npc();
			remove_npc();
			//Make all NPCs of the same alignment as victim hostile:
			npclist = AVATAR->find_nearby(-1, 80, MASK_NPC2);
			for (npc in npclist with index to count)
			{
				npcshape = npc->get_item_shape();
				if (!((npcshape == SHAPE_MALE_AVATAR) || (npcshape == SHAPE_FEMALE_AVATAR)))
				{
					if (npc->get_alignment() == alignment)
					{
						npc->set_alignment(2);
						npc->set_schedule_type(IN_COMBAT);
					}
				}
			}
		}
		else
		{
			//FoV 'NPCs' are temporary monsters carrying scrolls:
			ownedscrolls = get_cont_items(SHAPE_SCROLL, QUALITY_ANY, 4);
			if (ownedscrolls)
			{
				scrollquality = ownedscrolls->get_item_quality();
				body = false;
				if (scrollquality == 240)
				{
					//Erethian
					//Set flag to prevent respawning:
					gflags[0x02EE] = true;
					pos = get_object_position();
					//Create his body:
					body = UI_create_new_object(SHAPE_BODIES_3);
					body->set_item_frame_rot(get_item_frame_rot());
					body->set_item_frame(FRAME_MAGEBODY);
					//Clear inventory:
					clearInventory(item);
					UI_update_last_created(pos);
				}
				if (scrollquality == 241)
				{
					//Dracothraxus
					//Set flag to prevent respawning:
					gflags[0x02EF] = true;
					pos = get_object_position();
					//Create his body:
					body = UI_create_new_object(SHAPE_LARGE_BODIES);
					body->set_item_frame_rot(get_item_frame_rot());
					body->set_item_frame(FRAME_DRAGON_BODY);
					//Clear inventory:
					clearInventory(item);
					UI_update_last_created(pos);
				}
				//Create another scroll, with the same quality
				//as the one that was owned by Erethian or
				//Dracothraxus:
				scroll = UI_create_new_object(SHAPE_SCROLL);
				scroll->set_item_flag(TEMPORARY);
				scroll->set_item_quality(scrollquality);
				scroll->set_item_frame(4);
				//Put it in the body:
				body->give_last_created();
				script scroll after 1 ticks
				{
					finish;
					nohalt;
					//Not sure what it does:
					call makeStuffToBodies;
				}
				//Make all NPCs of the same alignment as victim hostile:
				npclist = AVATAR->find_nearby(-1, 80, MASK_NPC2);
				for (npc in npclist with index to count)
				{
					npcshape = npc->get_item_shape();
					if (!((npcshape == SHAPE_MALE_AVATAR) || (npcshape == SHAPE_FEMALE_AVATAR)))
					{
						if (npc->get_alignment() == alignment)
						{
							npc->set_alignment(2);
							npc->set_schedule_type(IN_COMBAT);
						}
					}
				}
			}
			else
			{
				//Kill monster npc:
				kill_npc();
				//Make all NPCs of the same alignment as victim hostile:
				npclist = AVATAR->find_nearby(-1, 80, MASK_NPC2);
				for (npc in npclist with index to count)
				{
					npcshape = npc->get_item_shape();
					if (!((npcshape == SHAPE_MALE_AVATAR) || (npcshape == SHAPE_FEMALE_AVATAR)))
					{
						if (npc->get_alignment() == alignment)
						{
							npc->set_alignment(2);
							npc->set_schedule_type(IN_COMBAT);
						}
					}
				}
			}
		}
	}
}

Blackrock_Potion shape#(0x450) ()
{
	if ((event == DOUBLECLICK) && get_item_frame() ==0)
	{
		//Nothing happens if in incomplete form.
		//Get random party member to ask the Avatar if he is SURE:
		var npc = randomPartyMember();
		npc.say("@If thou dost remember it, Zauriel said this was a deadly poison. @Art thou sure thou dost want to use it?@");
		if (askYesNo())
		{
			//Alas, yes...
			npc.hide();
			//Ask for target:
			var target = UI_click_on_item();
			
			if (target->is_npc())
			{
				//An NPC:
				if (target->get_item_shape() == SHAPE_LAURIANNA_ROOTED)
				{
					//Fortunatelly, it is Laurianna
					avatarSpeak("As you approach Laurianna with the potion, she immediatelly begins talking to you. You ignore her protests and force the potion down her throat.");
					gflags[LAURIANNA_DRANK_POTION] = true;
					script item after 1 ticks call Laurianna;
				}
				else
				{
					//Someone else... DAMN YOU AVATAR!
					var npc_num = target->get_npc_number();
					avatarSpeak("In a terrible display of strength and brutality, you force the potion down your victim's throat. The effect is swift, and everyone nearby is shocked by your brutal display.");
					if (npc_num == BATLIN)
					{
						//Batlin is a special case, but he IS affected:
						UI_show_npc_face(0xFFE6, 0x0000);
						say("Batlin squirms and contorts for a while, and chokes @Damn thee, Avatar!@ very faintly. In what appears to be a spasm, Batlin makes a gesture and vanishes before your eyes.");
						gflags[0x00DA] = true;
						UI_remove_npc(UI_get_npc_object(0xFFE6));
					}
					else
					{
						//Simply kill anyone else:
						say("After contorting for a while, your poor victim stops squirming and lays dead at your feet.");
						target->killTargetNPC();
					}
				}
				//Destroy the potion:
				remove_item();
			}
		}
	}
}

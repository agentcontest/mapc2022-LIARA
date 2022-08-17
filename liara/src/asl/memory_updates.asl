attached_agent(X,Y):- attached(X,Y) & team(Team) & thing(X,Y,entity,Team) & (math.abs(X) + math.abs(Y)) == 1.

/* Implements memory updates (things the agent needs to remember) */

+!update_memory(XMy,YMy) 
	<-	!update_dispensers(XMy,YMy);
		!update_roleZones(XMy,YMy);
		!update_goalZones(XMy,YMy);
		!fix_issues.
	
+!update_dispensers(XMy,YMy) 
	<- 	!add_dispenser(XMy,YMy);
		!move_to_dispenser(XMy,YMy).
		
+!add_dispenser(XMy,YMy):
	thing(XThing,YThing,dispenser,Parameters)[entity(Myname),source(percept)] &
	not(thing(XMy+XThing,YMy+YThing,dispenser,Parameters)[source(memory)]) 
	<- 	+thing(XMy+XThing,YMy+YThing,dispenser,Parameters)[source(memory)].
		
+!add_dispenser(XMy,YMy) <- true.

+!update_roleZones(XMy,YMy): 
	roleZone(XZone,YZone)[entity(Myname),source(percept)] & 
	not(roleZone(XMy+XZone,YMy+YZone)[source(memory)])
	<- 	+roleZone(XMy+XZone,YMy+YZone)[source(memory)];
		!move_to_roleZone(XMy+XZone,YMy+YZone,XMy,YMy).
	
+!update_roleZones(XMy,YMy) <- true.
	
+!update_goalZones(XMy,YMy): 
	goalZone(XZone,YZone)[entity(Myname),source(percept)] & 
	not(goalZone(XMy+XZone,YMy+YZone)[source(memory)])
	<- +goalZone(XMy+XZone,YMy+YZone)[source(memory)];
		!move_to_goalZone(XMy+XZone,YMy+YZone,XMy,YMy).
	
+!update_goalZones(XMy,YMy) <- true.


/* Goals based on Memory */	

/* perceives a [THING] of the type [DISPENSER], it is doing nothing then exploring,
 * it has no block of the same type then it will move to the dispenser to collect a block. */ 
+!move_to_dispenser(XMy,YMy): roleAbleBlocks & not(has_block(Parameters) & carryingMaxBlocks) &
		thing(XThing,YThing,dispenser,Parameters)[entity(Myname),source(percept)] 
		& not(movingToDispenser(XOther,YOther) & ( math.abs((XOther-XMy)+(YOther-YMy)) <= math.abs((XThing-XMy) + (YThing-YMy)) ))
	<-  -movingToDispenser(_,_); +movingToDispenser(XMy+XThing,YMy+YThing,Parameters).
	
+!move_to_dispenser(XMy,YMy) <- true.
	
/* perceives a [ROLEZONE] */ 
+!move_to_roleZone(XZone,YZone,XMy,YMy): my_role(Role) & not(role(Role)[_]) 
		& not(movingToRoleZone(XOther,YOther) & ( math.abs((XOther-XMy)+(YOther-YMy)) <= math.abs((XZone-XMy) + (YZone-YMy)) ))
	<- 	-movingToRoleZone(_,_); +movingToRoleZone(XZone,YZone).
	
+!move_to_roleZone(XZone,YZone,XMy,YMy) <- true.

/* In case it is going to a GoalZone and finds another closer it updates */
+!move_to_goalZone(XZone,YZone,XMy,YMy): 
		movingToGoalZone(XOther,YOther) & ( math.abs((XOther-XMy)+(YOther-YMy)) > math.abs((XZone-XMy) + (YZone-YMy)) ) 
	<- 	-movingToGoalZone(_,_); +movingToGoalZone(XZone,YZone).
	
+!move_to_goalZone(XZone,YZone,XMy,YMy) <- true.
	
/* In case it lose the block because a clear event */
+!fix_issues: not(attached(_,_)) & carrying_block <- -carrying_block.
/* In case it attaches with another agent */
+!fix_issues: attached_agent(X,Y) <- detach(X,Y).
+!fix_issues <- true.

+!fix_goalZones: position(XMy, YMy) & goalZone(XMy,YMy)[source(memory)] & not(goalZone(0,0)[source(percept)]) 
	<- 	-goalZone(XMy,YMy)[source(memory)];
		-goalZone(XMy-1,YMy)[source(memory)];
		-goalZone(XMy+1,YMy)[source(memory)];
		-goalZone(XMy-1,YMy-1)[source(memory)];
		-goalZone(XMy+1,YMy+1)[source(memory)];
		-goalZone(XMy,YMy-1)[source(memory)];
		-goalZone(XMy,YMy+1)[source(memory)];.
	
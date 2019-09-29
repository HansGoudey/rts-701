# Data For Each Node Type
For now most are added as member variables for the node scenes with the same names. In a many situations these relationships could be better managed as child / parent relationships between nodes.

For now each node is contained in its own file, but I'm not sure that's the best way to organize it.

**NOTE** *The data in the node structure is more up to date than this, but this can be an overview.

## Affiliation
Could possibly have multiple players attached, or at least that possibility could be left open, which is why this is separate data from the *Player.*
- **ID / Color**
- **Resource count**
- **Linked players**
- **Linked entities**
*Scope increase:*
- **Researched technologies** 

## Player
Should always be the child of an affiliation.

- **Linked affiliation**
- **Selection** List of selected entities
- **Camera Position and Rotation**

## Entity
Unanswered question is which of the nodes in the heirarchy Entity->Unit->UnitType should be the spacial node. I think the highest one in this heirarchy should be for the most grouped / common behavior.

- **Position and Rotation**
- **Affiliation** A link to a player or other ID
- **Health and Maximum Health**

### Unit
Will always be the child of an entity node. I'm not sure how to deal with different types of units yet. Should different types be children of the generic 'Unit' node or should they all be contained within the same unit. I'm guessing the former would be better.

- **Damage multiplier** 'Armor' specific to certain damage types
- **Action state** Countdown or position in the process of an action
- **Active action type** The effect an action will have upon completion
*Scope increase:*
- **Action upgrade status**
- **Order list** A stack of player assigned orders

### Building
Will always be the child of an entity node.

- **Production state** Countdown or position in process of unit / resource creation
*Upgrade status

### Projectile
- **Type**

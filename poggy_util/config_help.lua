-- ============================================================================
-- POGGY HELP SYSTEM - Content Configuration
-- Edit categories, sections, and items to customize the /help guide.
-- ============================================================================

Config = Config or {}

Config.HelpData = {

    -- ========================================================================
    -- GETTING STARTED
    -- ========================================================================
    {
        id    = "getting_started",
        title = "GETTING STARTED",
        icon  = "compass",
        color = "#d4c5a0",
        sections = {
            {
                title = "Voice Chat Setup",
                type  = "steps",
                items = {
                    "Press ESC to open the main menu",
                    "Navigate to SETTINGS → AUDIO",
                    "Toggle VOICECHAT to On",
                    "Any basic headset or built-in mic will work fine"
                }
            },
            {
                title = "Essential Hotkeys",
                type  = "info",
                items = {
                    "H — Call your horse when near a road",
                    "J — Call your wagon when near a road",
                    "I — Open your inventory",
                    "B — Open the clothing wheel menu",
                    "[ (Left Bracket) — Open the emotes menu",
                    "X — Raise your hands",
                    "Z — Toggle ragdoll",
                    "L — Point in front of you",
                    "U — Open interaction menu near objects"
                }
            },
            {
                title = "Useful Commands",
                type  = "info",
                items = {
                    "/rac or /rc — Reload character clothes",
                    "/emotes — Open the emotes menu (or press [ key)",
                    "/sethud — Customize HUD layout (ESC to save & close)",
                    "/shud — Hide or show the HUD",
                    "/mount — Ride side-saddle on your horse",
                    "/find — Open the location finder",
                    "/sell — Find shops buying your items",
                    "/cway — Clear your waypoint",
                    "/createstorage — Place custom storage at your location",
                    "/license — Open the license menu for special jobs"
                }
            },
            {
                title = "HUD Setup (Important!)",
                type  = "steps",
                items = {
                    "Type /sethud the first time you load in",
                    "Drag HUD elements (food, water, health, etc.) to where you want them on screen",
                    "Once positioned, press ESC to close and save your layout",
                    "Your HUD layout is saved and will persist across sessions"
                }
            },
            {
                title = "Emotes & Clothing",
                type  = "info",
                items = {
                    "Press B to open the clothing wheel — quickly change hats, masks, and accessories",
                    "Press [ (Left Bracket) or type /emotes to open the emote menu",
                    "Use Backspace to cancel any active emote",
                    "You can preview emotes before playing them and favorite the ones you use most"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Use the F6 menu to reload clothes, run animations, and access features",
                    "Type /find to search for any shop or location on the map",
                    "Open your inventory with I to manage items",
                    "Set up your HUD with /sethud right away — it only takes a moment"
                }
            }
        }
    },

    -- ========================================================================
    -- IN-COUNTY TERMS
    -- ========================================================================
    {
        id    = "terms",
        title = "RP TERMS",
        icon  = "book",
        color = "#b0a080",
        sections = {
            {
                title = "Roleplay Terminology",
                type  = "info",
                items = {
                    "Staff → Government",
                    "Server → County",
                    "Discord → Newspaper",
                    "In-county ID → Lucky / Special number",
                    "Going AFK → Going in my head / Thinking about something",
                    "Lagging / Low FPS → Headache",
                    "Game Crashed / Relogging → Head popped / Popping my head",
                    "Server Restart → Storm",
                    "FPS → Blinks",
                    "Leaving the game → Riding out / Taking the train out / Taking a nap",
                    "Hackers / Modders → Wizards",
                    "VDM / RDM → Crazy people",
                    "NPCs → Locals",
                    "Your other character → Your other pair of boots",
                    "Staff Report → Make a prayer",
                    "Banned → Sent to Mexico / Deported",
                    "Monitor / Screen → Eyes",
                    "Press a button → Flex your [key] muscle",
                    "Microphone → Voice box",
                    "Headset → Ears",
                    "Wrong button → Muscle spasm / Flexed the wrong muscle",
                    "Recording → Eyes rolling",
                    "Streaming → You got a Twitch in your eye",
                    "Clips → Memories"
                }
            }
        }
    },

    -- ========================================================================
    -- COMMANDS REFERENCE
    -- ========================================================================
    {
        id    = "commands",
        title = "COMMANDS",
        icon  = "terminal",
        color = "#a0a0c0",
        sections = {
            {
                title = "General",
                type  = "commands",
                items = {
                    "/rac or /rc — Reload character clothes",
                    "/emotes — Open emote menu (or press [ key)",
                    "/sethud — Customize HUD layout (ESC to save)",
                    "/shud — Hide or show the HUD",
                    "/hidedisease — Hide or show the disease panel on the right side",
                    "/movedisease — Drag the disease panel to reposition it (saves automatically)",
                    "/callpolice — Request law enforcement assistance",
                    "/calldoctor — Request medical help",
                    "/sendhelp — Self-revive when no doctor is available",
                    "/createstorage — Create custom, shareable storage",
                    "/scene — Create customizable text scenes",
                    "/extinguish — Remove a placed campfire nearby",
                    "/mypets — Manage your pets",
                    "/mount — Ride side-saddle on your horse",
                    "/find — Open the location finder",
                    "/sell — Find which shops will buy your items",
                    "/cway — Clear your waypoint",
                    "/camp — Manage your camp",
                    "/ranch — Manage your ranch",
                    "/license — Open the license menu",
                    "/hire — Hire or fire employees"
                }
            },
            {
                title = "Freecam",
                type  = "commands",
                items = {
                    "/freecam — Toggle freecam mode",
                    "/lockcam — Lock or unlock camera in freecam",
                    "/attachcam — Attach or detach camera from character",
                    "/followcam — Activate follow cam mode"
                }
            },
            {
                title = "Law Enforcement",
                type  = "commands",
                items = {
                    "/badge — Display your badge and credentials",
                    "/onduty — Go on duty (law or medical)",
                    "/offduty — Go off duty",
                    "/law — Open the Law Enforcement menu"
                }
            },
            {
                title = "Medical",
                type  = "commands",
                items = {
                    "/onduty — Go on duty as a Doctor",
                    "/offduty — Go off duty",
                    "/inspect — Inspect a nearby player's conditions (Doctor only)",
                    "/visit — Begin a medical visit with a nearby player (Doctor only)",
                    "/calldoctor — Alert on-duty Doctors you need help (when injured/downed)",
                    "/sendhelp — Request a self-revive NPC when no Doctor is available",
                    "/hidedisease — Hide or show the disease panel on the right side",
                    "/movedisease — Drag the disease panel to reposition it (saves automatically)"
                }
            },
            {
                title = "Economy & Realty",
                type  = "commands",
                items = {
                    "/house — Access your house menu and pay taxes",
                    "/license — Open the license menu for jobs",
                    "/hire — Hire or fire people from your business",
                    "/ranch — Open ranch management menu",
                    "/camp — Manage your camp",
                    "/sell — Find which shops will buy your items",
                    "/createstorage — Place custom storage anywhere"
                }
            }
        }
    },

    -- ========================================================================
    -- MAIL & POST
    -- ========================================================================
    {
        id    = "mail",
        title = "MAIL & POST",
        icon  = "envelope",
        color = "#c0b070",
        sections = {
            {
                title = "Registering Your PO Box",
                type  = "steps",
                items = {
                    "Find any black mailbox near train stations, streets, or town squares",
                    "Stand close and press G to open the mail interface",
                    "Click 'Register' to get a permanent PO number",
                    "Note your PO number — you'll use it to receive mail"
                }
            },
            {
                title = "Sending & Receiving Mail",
                type  = "info",
                items = {
                    "Approach any mailbox and press G to open it",
                    "Select 'Open Mail' and choose a recipient from Contacts or enter a PO number",
                    "Write your message, attach items if needed, and press Send",
                    "A small envelope icon appears when new mail is waiting",
                    "All mail stays until you delete it — keep your inbox tidy"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Share your PO number on business cards or posters",
                    "Each character gets a unique PO number — don't mix them up",
                    "You can read mail on the website at rosewoodridge.xyz/account (read-only)"
                }
            }
        }
    },

    -- ========================================================================
    -- HUNTING
    -- ========================================================================
    {
        id    = "hunting",
        title = "HUNTING",
        icon  = "crosshair",
        color = "#c08060",
        sections = {
            {
                title = "Basic Hunting",
                type  = "steps",
                items = {
                    "Purchase a rifle, bow, or hunting weapon from a gunsmith",
                    "Acquire appropriate ammunition for your weapon",
                    "Search for animal tracks and follow them to locate prey",
                    "Use stealth — approach animals from downwind",
                    "Aim for vital organs (head or heart) for clean kills",
                    "After killing, approach and skin to collect pelts and meat"
                }
            },
            {
                title = "Legendary Hunting",
                type  = "info",
                items = {
                    "Speak with Gus to get legendary hunting locations",
                    "Legendary animals have unique pelts for special crafting",
                    "Use tracking skills to find clues of legendary animal presence",
                    "Higher quality weapons provide better pelts"
                }
            },
            {
                title = "Selling Animal Parts",
                type  = "info",
                items = {
                    "Bring pelts, meat, and parts to any butcher in town",
                    "Pelts and carcasses can be stored in your inventory or on your horse",
                    "Carts and wagons hold larger carcasses in their inventory",
                    "Prices vary based on pelt quality and animal rarity"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Use binoculars to study animals from a distance",
                    "Clean kills provide higher quality pelts",
                    "Use /find to locate butchers and Gus locations"
                }
            }
        }
    },

    -- ========================================================================
    -- FISHING
    -- ========================================================================
    {
        id    = "fishing",
        title = "FISHING",
        icon  = "fish",
        color = "#60a0c0",
        sections = {
            {
                title = "Getting Started",
                type  = "steps",
                items = {
                    "Visit a Fishing Shop to purchase a fishing rod and spinner bait",
                    "Old fishing rods from Gunsmiths are deprecated and won't work",
                    "Find a suitable fishing location near bodies of water",
                    "Equip your fishing rod and cast your line into the water",
                    "Wait for a bite, then follow the prompts to reel it in"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Fishing is a great way to reduce character stress",
                    "Early morning and evening are ideal fishing times",
                    "Different water types (river, lake, ocean) contain different species",
                    "Fish can be sold to butchers or used in cooking recipes",
                    "There's a chance to find pearls while fishing"
                }
            }
        }
    },

    -- ========================================================================
    -- CAMPING
    -- ========================================================================
    {
        id    = "camping",
        title = "CAMPING",
        icon  = "tent",
        color = "#a09060",
        sections = {
            {
                title = "Setting Up Camp",
                type  = "steps",
                items = {
                    "Buy a camp item (tent, cot, table, etc.) from a Camp Outfitters shop — use /find to locate one",
                    "Travel to a wilderness area away from towns and roads (camps cannot be placed in town zones)",
                    "Open your inventory and use the camp item to enter placement mode",
                    "Use scroll wheel to rotate the object, then click to place it",
                    "Continue adding items — campfires, chairs, hitching posts, storage trunks, and more"
                }
            },
            {
                title = "Managing Your Camp",
                type  = "info",
                items = {
                    "Type /camp to manage permissions, storage, or remove your camp",
                    "Type /camp_load to refresh if your camp fails to load after a storm (restart)",
                    "Your camp supports a personal clothing wardrobe if you place a tent with clothes storage",
                    "You can grant other players access through the permissions menu",
                    "Camp items degrade over time — repair them with wood and rock materials"
                }
            },
            {
                title = "Available Camp Items",
                type  = "info",
                items = {
                    "Tents (Standard, Hunting, Large, Teepee) — shelter and wardrobe access",
                    "Campfires — cooking and crafting station",
                    "Tables, chairs, stools, benches — decoration and RP use",
                    "Hitching post — tie your horse at camp",
                    "Trunks and crates — extra camp storage",
                    "Ammunition workbench — craft ammo at camp",
                    "Caravan — mobile-style camp structure"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Camps cannot be placed inside town boundaries — find a nice spot in the wilderness",
                    "Avoid placing camps on roads or near high-traffic areas",
                    "Use your campfire for cooking and crafting recipes",
                    "Players can steal from unlocked camp storage — manage access carefully"
                }
            }
        }
    },

    -- ========================================================================
    -- MINING & GOLD PANNING
    -- ========================================================================
    {
        id    = "mining",
        title = "MINING",
        icon  = "pickaxe",
        color = "#909098",
        sections = {
            {
                title = "Mining",
                type  = "steps",
                items = {
                    "Purchase a pickaxe from a blacksmith shop",
                    "Locate mining areas — all nodes are in cave systems near unusual rock formations",
                    "Approach a mining node and interact with your pickaxe",
                    "Collect minerals: rocks, rubies, emeralds, diamonds, lead, copper, platinum, and more",
                    "Sell findings to blacksmith shops or use them in crafting"
                }
            },
            {
                title = "Gold Panning",
                type  = "steps",
                items = {
                    "Purchase a gold pan from a blacksmith shop",
                    "Find a river or stream with gold panning spots",
                    "Equip your gold pan and interact with the water",
                    "For efficiency, craft a Gold Cradle Stand at a blacksmith",
                    "The Gold Cradle also produces sand, useful for crafting glass"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Mining nodes drop random items — exploration is key",
                    "Consider getting a Miner's License (/license) for bonus materials",
                    "Sulfur from mining is essential for dynamite and some weapons",
                    "Sand from gold panning is used to craft glass at blacksmiths"
                }
            }
        }
    },

    -- ========================================================================
    -- FARMING
    -- ========================================================================
    {
        id    = "farming",
        title = "FARMING",
        icon  = "plant",
        color = "#70b070",
        sections = {
            {
                title = "Getting Started",
                type  = "steps",
                items = {
                    "Purchase seeds from a seed vendor (check /find for locations)",
                    "Some plants require a hoe tool — buy one from a blacksmith",
                    "Find a spot outside of town boundaries — you cannot plant in towns",
                    "Use the seed from your inventory to plant it in the ground",
                    "Fill a watering can at a water source, then water your plant (Q key)",
                    "Optionally apply fertilizer to speed up growth (Q to apply, E to skip)",
                    "Wait for the plant to fully grow, then harvest with Q"
                }
            },
            {
                title = "Fertilizer",
                type  = "info",
                items = {
                    "Fertilizer reduces plant growth time — higher quality = faster growth",
                    "Basic Fertilizer: 50% time reduction",
                    "Quality Fertilizer: 50% time reduction",
                    "Premium Fertilizer: 75% time reduction",
                    "Fertilizer can be obtained from ranching (animal waste) or purchased"
                }
            },
            {
                title = "Available Crops",
                type  = "info",
                items = {
                    "Fruits & Vegetables: Agarita, Lemon, Yarrow, Corn, and more",
                    "Each crop has unique growth times and harvest rewards",
                    "Seeds have a chance to drop extra seeds on harvest for replanting",
                    "Plant blips appear on your map so you can track your crops"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "You can have up to 50 plants at once",
                    "Empty watering cans can be refilled — keep one on hand",
                    "Farming products are used in cooking, crafting, and distilling",
                    "Plants are personal — only you can harvest what you planted"
                }
            }
        }
    },

    -- ========================================================================
    -- HORSE CARE
    -- ========================================================================
    {
        id    = "horses",
        title = "HORSES",
        icon  = "horse",
        color = "#b09060",
        sections = {
            {
                title = "Basic Horse Care",
                type  = "info",
                items = {
                    "Purchase horse treats and stimulants from stables",
                    "Feed your horse regularly to maintain its cores",
                    "Use the hoof hook to clean hooves when dirty",
                    "Excessive running wears down horseshoes — monitor their condition",
                    "Keep horse revival kits for emergencies"
                }
            },
            {
                title = "Horse Training & Breeding",
                type  = "info",
                items = {
                    "Purchase a Horse Trainer or Breeder License with /license",
                    "Visit designated training/breeding facilities",
                    "For training: interact with wild horses and follow prompts",
                    "For breeding: own two compatible horses and visit the breeding facility",
                    "Horse pregnancy lasts approximately 6 hours real-time"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Craft corn and honey horse treats for healthier alternatives",
                    "Trained horses can be sold for profit as a horse trainer",
                    "Cart and wagon damage can be repaired with kits from stables",
                    "Higher bonding with your horse improves its performance"
                }
            }
        }
    },

    -- ========================================================================
    -- CARTS & WAGONS
    -- ========================================================================
    {
        id    = "wagons",
        title = "WAGONS",
        icon  = "wheel",
        color = "#a08050",
        sections = {
            {
                title = "Acquiring Carts & Wagons",
                type  = "info",
                items = {
                    "Carts can be crafted at Wheelwright locations in major towns, or bought from stables",
                    "Different types (small, medium, large) require varying materials",
                    "Specialized wagons may have job-specific requirements"
                }
            },
            {
                title = "Wagon Capacities (Examples)",
                type  = "info",
                items = {
                    "Buggies — 125 inventory / 65 carcass capacity",
                    "Small Carts — 125-250 inventory / 65-85 carcass capacity",
                    "Hunter Cart — 500 inventory / 300 carcass capacity",
                    "Coaches — 250-500 inventory / 85-100 carcass capacity",
                    "Standard Wagons — 500-900 inventory / 100-150 carcass capacity",
                    "Wagon Armoured — 1000 inventory / 150 carcass capacity"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Larger wagons are slower but carry more",
                    "Match your wagon to your work — hunters need carcass space, traders need inventory",
                    "Wagons can be damaged and may need repairs — keep repair kits handy"
                }
            }
        }
    },

    -- ========================================================================
    -- CRAFTING
    -- ========================================================================
    {
        id    = "crafting",
        title = "CRAFTING",
        icon  = "hammer",
        color = "#c0a060",
        sections = {
            {
                title = "Basic Crafting",
                type  = "info",
                items = {
                    "Most crafting requires specific workbenches or campfires",
                    "Purchase a campfire from general stores for personal crafting",
                    "Gather materials from hunting, mining, and farming",
                    "Approach a crafting station and interact to see recipes"
                }
            },
            {
                title = "Blacksmithing",
                type  = "info",
                items = {
                    "Get a Blacksmith License with /license",
                    "Visit blacksmith shops for specialized crafting",
                    "Craft nails, tools, gold pans, glass, and refined metals",
                    "Use materials from mining in your recipes"
                }
            },
            {
                title = "Distilling",
                type  = "info",
                items = {
                    "Get a Distiller License with /license",
                    "Visit distilleries in Armadillo, Valentine, Rhodes, or Emerald",
                    "Craft various alcoholic beverages using plants and ingredients",
                    "Moonshine can only be crafted at special moonshine shacks"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Different stations unlock different recipes",
                    "Legendary animal parts are used in special weapon crafting",
                    "Glass (crafted from sand) is needed for binoculars and cameras",
                    "Sulfur is essential for crafting lanterns and explosives"
                }
            }
        }
    },

    -- ========================================================================
    -- CRIME
    -- ========================================================================
    {
        id    = "crime",
        title = "CRIME",
        icon  = "mask",
        color = "#d07070",
        sections = {
            {
                title = "Getting Started",
                type  = "info",
                items = {
                    "Always /bandanaon to hide your identity",
                    "Keep weapons and supplies hidden in your horse or camp",
                    "Scout the area before committing any crime to avoid witnesses"
                }
            },
            {
                title = "Witness System",
                type  = "info",
                items = {
                    "NPCs can witness your crimes — shooting, fighting, lassoing, trampling, and hijacking",
                    "When a witness sees you, a blip appears on your map showing their location",
                    "Witnesses will try to flee and report the crime to law enforcement",
                    "If a witness escapes far enough, law enforcement will be alerted automatically",
                    "You can stop a witness by catching them before they get away — but that might create more witnesses",
                    "Wearing a bandana helps hide your identity, but witnesses still report the crime itself",
                    "Law enforcement players receive alerts with your description and last known location"
                }
            },
            {
                title = "Fencing Stolen Goods",
                type  = "info",
                items = {
                    "Find the Fence NPC — use /find to locate them",
                    "Approach the Fence and press G to sell weapons and stolen goods",
                    "You can also browse and buy weapons from the Fence's stock (middle mouse button)",
                    "Prices vary — the Fence adds random variance to buy and sell prices",
                    "Customized weapons (engravings, custom parts) sell for a 20% bonus",
                    "Law enforcement and medical personnel cannot use the Fence"
                }
            },
            {
                title = "Drug & Moonshine Dealing",
                type  = "steps",
                items = {
                    "Buy alcohol at any saloon or craft moonshine (Distiller License required via /license)",
                    "Approach locals, right-click, and look for the sell prompt (G key)",
                    "If locals refuse, clear bad reputation with a Reputation Token at the church",
                    "Law must be on duty before illegal sales work"
                }
            },
            {
                title = "Bank Robbery",
                type  = "steps",
                items = {
                    "Get lockpicks from the Black Market Dealer or by looting locals",
                    "Secure a hostage — keep them fed and watered",
                    "Lockpick the bank door (W-A-S-D mini-game)",
                    "Negotiate escape terms with law",
                    "Use horse stimulants for long getaways — break line-of-sight"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Low reputation makes locals hostile — keep it clean when possible",
                    "Law is required to be on duty for illegal sales and heists",
                    "Bandanas drop automatically if you're downed",
                    "Horse stimulants are life-savers during long pursuits",
                    "Witnesses are more likely in towns — commit crimes in remote areas for fewer eyes",
                    "The Fence won't deal with you if you have a law or medical job"
                }
            }
        }
    },

    -- ========================================================================
    -- LAW ENFORCEMENT
    -- ========================================================================
    {
        id    = "law",
        title = "LAW & ORDER",
        icon  = "badge",
        color = "#7090d0",
        sections = {
            {
                title = "Duty Commands",
                type  = "commands",
                items = {
                    "/onduty — Go on duty for law enforcement",
                    "/offduty — Go off duty",
                    "/law — Open the Law Enforcement menu",
                    "/badge — Display your badge and credentials"
                }
            },
            {
                title = "For Citizens",
                type  = "info",
                items = {
                    "/callpolice — Send a local to fetch a lawman",
                    "Obey the law or face fines, jail time, or a bounty",
                    "Witnesses can report crimes — be careful who sees you"
                }
            }
        }
    },

    -- ========================================================================
    -- MEDICAL
    -- ========================================================================
    {
        id    = "medical",
        title = "MEDICAL",
        icon  = "medcross",
        color = "#d07070",
        sections = {
            {
                title = "Doctor Commands",
                type  = "commands",
                items = {
                    "/onduty — Go on duty as a Doctor (required to treat patients)",
                    "/offduty — Go off duty",
                    "/inspect — Inspect a nearby player's conditions and vital signs",
                    "/visit — Start a medical visit with a nearby player"
                }
            },
            {
                title = "For Patients",
                type  = "commands",
                items = {
                    "/calldoctor — Send an alert to all on-duty Doctors with your location",
                    "/sendhelp — Request a self-revive NPC when no Doctor is available",
                    "/hidedisease — Toggle the disease/illness panel (right side of screen)",
                    "/movedisease — Enter drag mode to reposition the disease panel (position saves per character)"
                }
            },
            {
                title = "Injuries (Physical)",
                type  = "info",
                items = {
                    "Bleeding — Caused by gunshots and blade wounds. Treat with Bandage, Herbal Bandage, Army Bandage, or Tourniquet",
                    "Wound Infection — Develops from untreated wounds. DOES NOT auto-heal. Requires Antibiotic or Doctor treatment",
                    "Broken Bone — From falls or impacts. Treat with Splint (partial) or a Doctor (full cure)"
                }
            },
            {
                title = "Diseases",
                type  = "info",
                items = {
                    "Common Cold — From cold/wet conditions. Auto-heals in ~30 min. Treat with Antibiotic or Herbal Medicine",
                    "Snake Bite — From snake encounter. DOES NOT auto-heal. Treat immediately with Antidote (Anti-Poison Remedy)",
                    "Malaria — From the Bayou/Lemoyne swamp zones (zone-based). DOES NOT auto-heal. Treat with Insect Bite Remedy",
                    "Cholera — From contaminated zone (far west). DOES NOT auto-heal. Treat with Antibiotic (40% chance) or Herbal Medicine (20% chance). Doctor's Health Elixir cures at 80% — severe cases, see a Doctor",
                    "Dysentery — From dirty conditions. Auto-heals in ~1 hour. Treat with Herbal Medicine or Antibiotic",
                    "Heat Stroke — From heat + sun + exertion. Auto-heals in ~20 min if you cool down. Treat with Restorative"
                }
            },
            {
                title = "Disease HUD",
                type  = "info",
                items = {
                    "A panel on the right side of your screen shows active illnesses and conditions at all times",
                    "A green MASK ON indicator appears at the top when your bandana/mask is covering your face — this means you are protected from respiratory diseases (Influenza, Typhoid, TB)",
                    "/hidedisease — Hide or show the entire panel (toggle)",
                    "/movedisease — Drag the panel to any position on screen. Release to save. Position is saved per character"
                }
            },
            {
                title = "Reviving Downed Players",
                type  = "info",
                items = {
                    "Syringe — Doctor-only item, primary revive (~20 second application)",
                    "Lavender Smelling Salts — Doctor-only item, faster revive (~15 seconds)",
                    "Doctors can also inspect patients mid-combat using /inspect to see active conditions"
                }
            },
            {
                title = "Doctor Clinics",
                type  = "info",
                items = {
                    "Doctor offices are in: Valentine, Strawberry, Blackwater, Rhodes, Saint Denis, Annesburg, Armadillo",
                    "Prescription items (Army Bandage, Antidote, Antibiotic, etc.) are only available from on-duty Doctors",
                    "Morphine and Health Elixir are administered by Doctors directly — you cannot buy them yourself"
                }
            }
        }
    },

    -- ========================================================================
    -- ECONOMY
    -- ========================================================================
    {
        id    = "economy",
        title = "ECONOMY",
        icon  = "coins",
        color = "#d0c060",
        sections = {
            {
                title = "Property & Housing",
                type  = "info",
                items = {
                    "/house — Access your house menu and pay taxes",
                    "Properties can be purchased through realtors",
                    "Pay taxes regularly to avoid losing your home"
                }
            },
            {
                title = "Buying a Business",
                type  = "info",
                items = {
                    "Walk up to available shops — General Stores, Gunsmiths, Saloons, Blacksmiths, Stables, etc.",
                    "If the shop is available for purchase, you'll see a purchase prompt",
                    "Buy the business and wait for the next storm (restart) for it to become fully operational",
                    "You will automatically receive the correct job for that shop type upon purchase",
                    "Use /hire to manage employees — hire, fire, and set ranks",
                    "Business owners at rank 2+ can access the hiring menu"
                }
            },
            {
                title = "Licenses & Jobs",
                type  = "info",
                items = {
                    "/license — Open the license menu",
                    "Available licenses: Miner, Lumberjack, Blacksmith, Distiller, Horse Trainer, Horse Breeder, Wheelwright",
                    "Some licenses are optional but grant bonus rewards (e.g., Miner's License)",
                    "Others are required to operate certain businesses (e.g., Distiller, Blacksmith)",
                    "You can surrender a license from the /license menu if you no longer need it"
                }
            },
            {
                title = "Selling Your Items",
                type  = "info",
                items = {
                    "Type /sell to open the Sell Finder — it scans your inventory for sellable items",
                    "The Sell Finder checks both NPC admin shops and player-owned shops for buy listings",
                    "Click an item to see every shop currently buying it, sorted by nearest distance",
                    "Switch between distance and price sorting to find the best deal or closest shop",
                    "Clicking a shop sets a GPS waypoint directly to it — same as /find"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Player shops can be found with /find under 'Player Shop'",
                    "Businesses generate income — restock and manage them regularly",
                    "License prices vary: $25 for basic licenses, $150 for trade licenses",
                    "Use /sell before visiting a shop to compare prices across town"
                }
            }
        }
    },

    -- ========================================================================
    -- RANCHING
    -- ========================================================================
    {
        id    = "ranching",
        title = "RANCHING",
        icon  = "horse",
        color = "#b08050",
        sections = {
            {
                title = "Buying a Ranch",
                type  = "steps",
                items = {
                    "Find a ranch location — look for ranch blips on the map or use /find",
                    "Approach the ranch NPC and interact to purchase",
                    "Ranches cost $240 — you can only own one ranch at a time",
                    "Once purchased, you gain access to the ranch management menu with /ranch"
                }
            },
            {
                title = "Buying & Managing Animals",
                type  = "info",
                items = {
                    "Use /ranch to open the ranch menu and buy animals",
                    "Available animals: Cows, Chickens, Pigs, Sheep, Goats, and Horses",
                    "Each animal type has a maximum you can buy and breed up to",
                    "Animals age over time, produce products, and can breed with each other",
                    "Use /animal to reposition animals within your ranch area"
                }
            },
            {
                title = "Feeding & Care",
                type  = "info",
                items = {
                    "Fill troughs with food (corn) and water (watering can) to keep animals fed",
                    "Animals eat from troughs automatically when hungry or thirsty",
                    "You can also hand-feed animals directly for a bonding bonus",
                    "Keep animals satisfied — low satisfaction reduces health and product output",
                    "Clean up animal waste regularly (gives Fertilizer for farming)",
                    "Use medicine items (Pet Revive) to heal sick animals"
                }
            },
            {
                title = "Products & Income",
                type  = "info",
                items = {
                    "Happy animals produce items over time — e.g., cows produce milk",
                    "Higher satisfaction and level means more products per cycle",
                    "Animals gain experience over time — leveling up increases production by up to 1.9x",
                    "Collect products when they reach the minimum threshold",
                    "Animals can be sold from the ranch menu once they reach a minimum age",
                    "Ranch storage is available for storing items if enabled"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Fertilizer from cleaning waste is great for farming — saves money on buying it",
                    "Young animals are fed by their mothers until age 3 — no need to hand-feed babies",
                    "Walking animals around gives satisfaction and experience bonuses",
                    "Animals can die of old age — breed replacements before that happens"
                }
            }
        }
    },

    -- ========================================================================
    -- CUSTOM STORAGE
    -- ========================================================================
    {
        id    = "storage",
        title = "CUSTOM STORAGE",
        icon  = "hammer",
        color = "#9090a0",
        sections = {
            {
                title = "Creating Storage",
                type  = "steps",
                items = {
                    "Stand at any location where you want to place a storage chest",
                    "Type /createstorage to create a storage at your current position",
                    "Storage creation costs $5 — the chest blip appears on your map",
                    "You can create up to 2 custom storages per character"
                }
            },
            {
                title = "Using & Managing Storage",
                type  = "info",
                items = {
                    "Walk up to your storage chest (within 2m) and press G to open it",
                    "Default capacity is 200 slots — upgrade for $1.50 per 25 extra slots",
                    "Share access with other players through the management menu",
                    "You can also grant job-based access (e.g., let all sheriffs access your armory)",
                    "Rename your storage to keep things organized"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Storage blips only show for players who have access",
                    "Unused storages are automatically deleted after 60 days of inactivity",
                    "Place storage near your camp or business for convenient access",
                    "Admins can move or delete storage with /movestorage and /deletestorage"
                }
            }
        }
    },

    -- ========================================================================
    -- LICENSING
    -- ========================================================================
    {
        id    = "licensing",
        title = "LICENSING",
        icon  = "badge",
        color = "#c0a870",
        sections = {
            {
                title = "How Licensing Works",
                type  = "info",
                items = {
                    "Type /license to open the license menu",
                    "Licenses grant you a specific job and unlock related abilities",
                    "Some licenses are optional but give bonuses (e.g., Miner, Lumberjack)",
                    "Others are required to operate certain businesses (e.g., Blacksmith, Distiller)",
                    "You can surrender a license at any time from the /license menu"
                }
            },
            {
                title = "Available Licenses",
                type  = "info",
                items = {
                    "Miner's License ($25) — Bonus rewards while mining (not required to mine)",
                    "Lumberjack License ($25) — Bonus rewards while logging (not required to chop)",
                    "Blacksmith License ($150) — Required to operate blacksmith facilities and sell crafted goods",
                    "Distiller's License ($150) — Required to run a distillery and craft alcohol",
                    "Horse Trainer License ($150) — Operate a horse training facility",
                    "Horse Breeder License ($150) — Operate a horse breeding facility",
                    "Wheelwright License ($150) — Operate a wheelwright facility and build wagons"
                }
            },
            {
                title = "Hiring System",
                type  = "info",
                items = {
                    "Business owners can use /hire to manage employees",
                    "You must be rank 2 (Manager) or higher to access the hiring menu",
                    "Hire nearby players, set their rank, or fire them",
                    "Employees at different ranks have different permissions"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "$25 licenses give optional bonuses — worth buying if you do that activity often",
                    "$150 licenses are trade licenses that unlock business operation",
                    "You don't need a license to work as an employee — only to own/operate",
                    "Run /license regularly to check what's available"
                }
            }
        }
    },

    -- ========================================================================
    -- AUCTION HOUSE
    -- ========================================================================
    {
        id    = "auction_house",
        title = "AUCTION HOUSE",
        icon  = "gavel",
        color = "#638cff",
        sections = {
            {
                title = "What Is the Auction House?",
                type  = "info",
                items = {
                    "The Auction House lets you list items for sale to other players",
                    "Buyers can place bids or buy items outright at the buyout price",
                    "Proceeds and purchased items are delivered to your mailbox",
                    "Locations: Valentine, Blackwater, Saint Denis, and Armadillo",
                    "Use /find and search 'Auction' to get directions"
                }
            },
            {
                title = "Selling an Item",
                type  = "steps",
                items = {
                    "Approach an Auction House NPC and press G to open the interface",
                    "Click the 'Sell' tab at the top",
                    "Select an item from your inventory on the left panel",
                    "Set a starting price and optionally a buyout price",
                    "Choose an auction duration (2h, 8h, 24h, or 48h)",
                    "Review the fee breakdown (deposit + estimated sales tax)",
                    "Click 'LIST ITEM' to post your auction"
                }
            },
            {
                title = "Buying & Bidding",
                type  = "steps",
                items = {
                    "Open the Auction House and browse listings on the 'Browse' tab",
                    "Use the search bar, category sidebar, and sort options to find items",
                    "Click 'Bid' to place a bid above the current minimum",
                    "Click 'Buyout' to purchase immediately at the listed buyout price",
                    "If you're outbid, your money is refunded to your mailbox automatically"
                }
            },
            {
                title = "Managing Your Auctions",
                type  = "info",
                items = {
                    "'My Auctions' tab shows all your active, sold, expired, and cancelled listings",
                    "'My Bids' tab shows all active auctions you've bid on and whether you're winning",
                    "You can cancel your own auction from the Browse tab or My Auctions tab",
                    "Cancelling an auction with no bids returns your item via the mailbox",
                    "If an auction expires with bids, it sells to the highest bidder automatically"
                }
            },
            {
                title = "Mailbox & Collecting",
                type  = "info",
                items = {
                    "The 'Mailbox' tab holds items you've won and money from sales",
                    "Click 'Collect' next to an entry to receive it, or 'Collect All' at the top",
                    "Sale proceeds have the 5% sales tax already deducted",
                    "Outbid refunds appear in your mailbox automatically"
                }
            },
            {
                title = "Fees & Deposits",
                type  = "info",
                items = {
                    "A non-refundable deposit is charged when you list an item",
                    "Deposit rate depends on duration: 5% (2h), 10% (8h), 15% (24h), 20% (48h)",
                    "A 5% sales tax is taken from the final sale price when the auction completes",
                    "The fee breakdown is shown before you confirm your listing"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Set a reasonable buyout price to attract impulse buyers",
                    "Shorter auctions have lower deposits but less time for bids",
                    "Check 'My Bids' regularly to see if you've been outbid",
                    "Your own listings show a Cancel button instead of Bid/Buyout in Browse",
                    "You can have up to 20 active listings at a time"
                }
            }
        }
    },
    {
        id    = "drugs",
        title = "DRUG MANUFACTURING",
        icon  = "plant",
        color = "#a070e0",
        sections = {
            {
                title = "Drug Manufacturing Guide",
                type  = "drug-crafting",
                note  = "Drug manufacturing is an illegal criminal activity in RedM. Being caught carries heavy in-game penalties.",
                drugs = {
                    {
                        id          = "cocaine",
                        name        = "Cocaine",
                        image       = "drug_cocaine",
                        color       = "#c8c8ff",
                        description = "A powerful stimulant refined from coca leaves through a multi-stage chemical process.",
                        stats       = { value = "$$$$", risk = "Extreme", stages = "4" },
                        acquisition = "Buy Coca Seeds ($0.80 ea) from the Black Market. Grow to get Coca Leaves.",
                        use         = "Use on yourself for an intense stimulant buff.",
                        steps = {
                            {
                                stage    = "Stage 1",
                                name     = "Coca Leaf Processing",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "cocaleaves", count = 7, name = "Coca Leaves" }
                                },
                                output   = { item = "raw_cocaine", count = 1, name = "Raw Cocaine" }
                            },
                            {
                                stage    = "Stage 2",
                                name     = "Acid Treatment",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "raw_cocaine", count = 1, name = "Raw Cocaine" },
                                    { item = "acid",        count = 2, name = "Acid" }
                                },
                                output   = { item = "acidified_cocaine_solution", count = 1, name = "Acidified Solution" }
                            },
                            {
                                stage    = "Stage 3",
                                name     = "Extraction",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "acidified_cocaine_solution", count = 1, name = "Acidified Solution" }
                                },
                                output   = { item = "refined_cocaine_extract", count = 1, name = "Refined Extract" }
                            },
                            {
                                stage    = "Stage 4",
                                name     = "Final Refinement",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "refined_cocaine_extract", count = 3, name = "Refined Extract" }
                                },
                                output   = { item = "drug_cocaine", count = 1, name = "Cocaine" }
                            }
                        }
                    },
                    {
                        id          = "heroin",
                        name        = "Heroin",
                        image       = "drug_heroin",
                        color       = "#c87878",
                        description = "An opiate derived from poppy plants, requiring solvent-based refinement.",
                        stats       = { value = "$$$", risk = "High", stages = "3" },
                        acquisition = "Buy Poppy Seeds from the Black Market. Grow to get Poppy Leaves.",
                        use         = "Use on yourself for a sedative painkiller effect.",
                        steps = {
                            {
                                stage    = "Stage 1",
                                name     = "Opium Extraction",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "poppyleaves", count = 7, name = "Poppy Leaves" }
                                },
                                output   = { item = "raw_opium", count = 1, name = "Raw Opium" }
                            },
                            {
                                stage    = "Stage 2",
                                name     = "Solvent Dilution",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "raw_opium",      count = 1, name = "Raw Opium" },
                                    { item = "heroin_solvent", count = 2, name = "Heroin Solvent" }
                                },
                                output   = { item = "opium_solution", count = 1, name = "Opium Solution" }
                            },
                            {
                                stage    = "Stage 3",
                                name     = "Final Processing",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "opium_solution", count = 3, name = "Opium Solution" }
                                },
                                output   = { item = "drug_heroin", count = 1, name = "Heroin" }
                            }
                        }
                    },
                    {
                        id          = "hash",
                        name        = "Hash",
                        image       = "drug_hash",
                        color       = "#a070e0",
                        description = "Compressed cannabis resin refined using a solvent wash process.",
                        stats       = { value = "$$$", risk = "Medium", stages = "3" },
                        acquisition = "Buy Cannabis Seeds from the Black Market. Grow to get Cannabis Leaves.",
                        use         = "Use on yourself for a relaxing body-high effect.",
                        steps = {
                            {
                                stage    = "Stage 1",
                                name     = "Resin Extraction",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "cannabisleaves", count = 7, name = "Cannabis Leaves" }
                                },
                                output   = { item = "raw_cannabis_resin", count = 1, name = "Raw Resin" }
                            },
                            {
                                stage    = "Stage 2",
                                name     = "Solvent Wash",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "raw_cannabis_resin", count = 1, name = "Raw Resin" },
                                    { item = "hash_solvent",       count = 2, name = "Hash Solvent" }
                                },
                                output   = { item = "unrefined_hash", count = 1, name = "Unrefined Hash" }
                            },
                            {
                                stage    = "Stage 3",
                                name     = "Compression",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "unrefined_hash", count = 3, name = "Unrefined Hash" }
                                },
                                output   = { item = "drug_hash", count = 1, name = "Hash" }
                            }
                        }
                    },
                    {
                        id          = "mushrooms",
                        name        = "Magic Mushrooms",
                        image       = "drug_magicmushroom",
                        color       = "#50c090",
                        description = "Psychedelic fungi cultivated and concentrated using a catalyst.",
                        stats       = { value = "$$", risk = "Low", stages = "2" },
                        acquisition = "Buy Mushroom Spores from the Black Market. Grow Fresh Mushrooms.",
                        use         = "Use on yourself for a hallucinogenic vision effect.",
                        steps = {
                            {
                                stage    = "Stage 1",
                                name     = "Drying",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "fresh_mushroom", count = 5, name = "Fresh Mushrooms" },
                                    { item = "water",          count = 1, name = "Water" }
                                },
                                output   = { item = "dried_mushroom", count = 1, name = "Dried Mushrooms" }
                            },
                            {
                                stage    = "Stage 2",
                                name     = "Catalyst Infusion",
                                location = "Drug Table",
                                inputs   = {
                                    { item = "dried_mushroom",      count = 3, name = "Dried Mushrooms" },
                                    { item = "psychedelic_catalyst", count = 1, name = "Psychedelic Catalyst" }
                                },
                                output   = { item = "drug_magicmushroom", count = 1, name = "Magic Mushrooms" }
                            }
                        }
                    },
                    {
                        id          = "marijuana",
                        name        = "Marijuana",
                        image       = "marijuana_jar1",
                        color       = "#70b840",
                        description = "Cannabis flower cured and processed into joints or premium honey blunts.",
                        stats       = { value = "$$", risk = "Low", stages = "3" },
                        acquisition = "Buy Cannabis Seeds from the Black Market. Grow Cannabis Leaves → harvest buds.",
                        use         = "Smoke a joint or blunt for a mild relaxation effect.",
                        steps = {
                            {
                                stage    = "Stage 1",
                                name     = "Bud Drying",
                                location = "Crafting Station",
                                inputs   = {
                                    { item = "cannabisleaves", count = 5, name = "Cannabis Leaves" },
                                    { item = "water",          count = 1, name = "Water" }
                                },
                                output   = { item = "marijuana_bud2", count = 1, name = "Marijuana Bud" }
                            },
                            {
                                stage    = "Stage 2A",
                                name     = "Roll Joint",
                                location = "Crafting Station",
                                inputs   = {
                                    { item = "marijuana_bud2", count = 1, name = "Marijuana Bud" },
                                    { item = "paper",          count = 1, name = "Paper" }
                                },
                                output   = { item = "marijuana_joint3_6", count = 1, name = "Joint" }
                            },
                            {
                                stage    = "Stage 2B",
                                name     = "Roll Honey Blunt",
                                location = "Crafting Station",
                                inputs   = {
                                    { item = "marijuana_bud2", count = 2, name = "Marijuana Bud" },
                                    { item = "honey",          count = 1, name = "Honey" },
                                    { item = "paper",          count = 1, name = "Paper" }
                                },
                                output   = { item = "honey_blunt", count = 1, name = "Honey Blunt" }
                            }
                        }
                    }
                }
            },
            {
                title = "Crime Tips",
                type  = "tips",
                items = {
                    "Seeds and solvents are purchased from the Black Market",
                    "Drug Tables can be found at hidden locations — ask around",
                    "Growing plants takes real time — check back later",
                    "Carrying drugs increases your wanted level if searched",
                    "Sell drugs to dealers or other players for maximum profit"
                }
            }
        }
    },

    -- ========================================================================
    -- INJURIES & TREATMENT
    -- ========================================================================
    {
        id    = "injuries",
        title = "INJURIES",
        icon  = "heart",
        color = "#c04040",
        sections = {
            {
                title = "About the Injury System",
                type  = "info",
                items = {
                    "Getting shot, burned, or falling from your horse can leave you with a lasting injury condition",
                    "Conditions are rated Mild (Sev 1), Moderate (Sev 2), or Severe (Sev 3)",
                    "Effects worsen with severity — slow movement, blurred vision, health drain, and more",
                    "Always seek a Doctor first — they treat faster and can fully clear Severe injuries",
                    "Self-treatment requires you to be out of combat for at least 6 seconds",
                    "All conditions clear automatically when you respawn"
                }
            },
            {
                title = "Bleeding",
                type  = "info",
                items = {
                    "Caused by: gunshots and most firearm wounds",
                    "Effect: health drains over time — Severe bleeding can be fatal if left untreated",
                    "Mild / Moderate — use a Bandage or Herbal Bandage (self-treatable)",
                    "Severe — use an Army Bandage or Tourniquet to stop the bleed",
                    "Buy at: General Store or from a Doctor",
                    "Tip: a Tourniquet stops Severe bleeding but leaves a lingering debuff — see a Doctor to remove it fully"
                }
            },
            {
                title = "Broken Bone",
                type  = "info",
                items = {
                    "Caused by: falling from height, melee hits, explosions",
                    "Effect: leg break = slowed sprint or limp; arm break = aim sway and inability to aim at Severe",
                    "Self-treatment: a Splint reduces severity by 1 — it will NOT fully clear a Severe break",
                    "Full recovery requires a Doctor to clear it properly",
                    "Buy at: General Store or from a Doctor",
                    "Tip: a Splint is still worth using mid-fight to bring Severe → Moderate and restore partial movement"
                }
            },
            {
                title = "Concussion",
                type  = "info",
                items = {
                    "Caused by: blunt blows to the head, explosions near your character",
                    "Effect: screen wobble, radial blur, muffled audio — Severe causes intermittent blackouts",
                    "Mild / Moderate — use Smelling Salts to clear the concussion yourself",
                    "Severe — Smelling Salts can reduce it, but see a Doctor for a full clear",
                    "Buy at: from a Doctor (Doctor-crafted item)",
                    "Tip: Smelling Salts work even during active combat — no out-of-combat requirement"
                }
            },
            {
                title = "Burns",
                type  = "info",
                items = {
                    "Caused by: Molotov cocktails, dynamite, flaming arrows, being set on fire",
                    "Effect: health drain over time; Severe burns drain stamina regeneration and cause random flinch",
                    "Mild / Moderate — use Creekplum Healing Salve (self-treatable, no combat restriction)",
                    "Severe — use a Burn Salve for maximum relief; available from a Doctor",
                    "Buy at: Creekplum Salve at General Store / Doctor; Burn Salve from a Doctor only",
                    "Tip: salves can be applied in the middle of a fight — useful for fire-heavy encounters"
                }
            },
            {
                title = "Shock",
                type  = "info",
                items = {
                    "Caused by: taking large amounts of damage in a short window (e.g. ambush, explosion)",
                    "Effect: halved stamina regen, grey peripheral vision, muffled audio — Severe adds input delay",
                    "Mild — a Health Tonic or Medicine can reduce Shock",
                    "Moderate / Severe — use Special Health Tonic or Stimulant Tonic for fast recovery",
                    "Severe Shock can also be treated by a Doctor with Morphine for instant full relief",
                    "Buy at: Health Tonic at General Store; Special Tonic and Stimulant Tonic from a Doctor"
                }
            },
            {
                title = "Outbreak Diseases",
                type  = "info",
                items = {
                    "Some diseases are only active during server-wide OUTBREAK events — watch for the HEALTH ALERT notification",
                    "Wearing a bandana over your face blocks most respiratory and contact diseases",
                    "CHOLERA — outbreak zone: Lemoyne riverbanks. Fast-escalating waterborne disease. Bandana helps",
                    "MALARIA — outbreak zone: Roanoke Valley swamps. Mosquito-borne. Bandana does NOT help",
                    "DYSENTERY — outbreak only, no fixed zone. NPC proximity spread. Auto-heals ~1 hr. Bandana does not help",
                    "TYPHOID — outbreak zones: Saint Denis docks & Thieves' Landing. Zone + NPC contact. Bandana helps",
                    "YELLOW FEVER — outbreak zones: southern bayou & Blackwater. Mosquito-borne zone. Bandana does NOT help",
                    "INFLUENZA — outbreak only, no fixed zone. NPC proximity spread. Auto-heals ~90 min. Bandana blocks it",
                    "TUBERCULOSIS — outbreak zones: Valentine & Saint Denis. Chronic illness. Persists through death. Bandana helps"
                }
            },
            {
                title = "Tuberculosis",
                type  = "info",
                items = {
                    "TB is a chronic illness — unlike other diseases, it PERSISTS THROUGH DEATH and does not clear on respawn",
                    "Contracted by: extended time near infected NPCs in Valentine or Saint Denis (outbreak only)",
                    "Very hard to contract — requires prolonged exposure (~15-30 min in zone without a bandana)",
                    "Symptoms: periodic coughing fits, rare dizzy/collapse episodes, mild stamina drain over time",
                    "Cure probability: Antibiotic 5% only — multiple doses needed, and may still not work",
                    "Very rare chance (~4 hrs) the body fights it off naturally — most need a Doctor",
                    "Wear a bandana when visiting Valentine or Saint Denis during a TB outbreak"
                }
            },
            {
                title = "Quick Item Reference",
                type  = "info",
                items = {
                    "Bandage         → Stops bleeding Mild/Moderate (General Store)",
                    "Herbal Bandage  → Same as Bandage with a herbal boost (General Store / Doctor)",
                    "Army Bandage    → Stops any level of bleeding (General Store / Doctor)",
                    "Tourniquet      → Emergency stop for Severe bleed — Doctor follow-up needed (Doctor)",
                    "Splint          → Reduces Broken Bone by 1 severity (General Store / Doctor)",
                    "Smelling Salts  → Treats Concussion Mild/Moderate (Doctor)",
                    "Creekplum Salve → Treats Burns Mild/Moderate (General Store / Doctor)",
                    "Burn Salve      → Treats any level of Burns (Doctor)",
                    "Health Tonic    → Reduces Mild Shock (General Store / Doctor)",
                    "Special Tonic   → Clears Shock up to Severe (Doctor)",
                    "Stimulant Tonic → Clears Shock + stamina boost (Doctor)",
                    "Morphine        → Doctor-use item for Severe Shock and trauma (Doctor)"
                }
            },
            {
                title = "Tips",
                type  = "tips",
                items = {
                    "Carry at least one Bandage and one Health Tonic before heading into dangerous territory",
                    "A Splint and a Creekplum Salve are cheap and cover two injury types — good general kit",
                    "Injury items can be bought from any Doctor on duty or at the General Store",
                    "Type /find doctor to locate the nearest on-duty Doctor",
                    "You cannot self-treat while sprinting or firing — find cover first"
                }
            }
        }
    },

    -- ========================================================================
    -- MEDICINES
    -- ========================================================================
    {
        id    = "medicines",
        title = "MEDICINES",
        icon  = "medcross",
        color = "#7ec8a2",
        sections = {
            {
                title = "How Medicines Work",
                type  = "info",
                items = {
                    "Most medicines are used directly from your inventory while out of combat.",
                    "Conditions show the illness or injury treated, and the chance of success.",
                    "DOCTOR ONLY items can only be used by a Doctor character.",
                    "HP shows how much health is restored on use.",
                    "Body Heal items treat specific injured body parts (wounds, bones, burns).",
                    "Buy medicines at the Doctor's shop or the General Store."
                }
            },
            {
                title = "Bleeding Treatments",
                type  = "medicine-grid",
                medicines = {
                    {
                        item = "bandage",
                        name = "Bandage",
                        desc = "Stops active bleeding with a short-duration wound dressing.",
                        conditions = {
                            { label = "Bleeding", pct = 100, color = "#e05050" },
                        },
                        health = 200,
                    },
                    {
                        item = "consumable_bandage_herbal",
                        name = "Herbal Bandage",
                        desc = "Herb-infused bandage. Superior hold and mild healing properties.",
                        conditions = {
                            { label = "Bleeding", pct = 100, color = "#e05050" },
                        },
                        health = 250,
                    },
                    {
                        item = "army_bandage",
                        name = "Army Bandage",
                        desc = "Military-grade bandage. Permanently stops any bleeding wound.",
                        conditions = {
                            { label = "Bleeding", pct = 100, color = "#e05050" },
                        },
                        health = 300,
                        permanent = true,
                    },
                    {
                        item = "tourniquet",
                        name = "Tourniquet",
                        desc = "Emergency bleed stop. Leaves a debuff — see a Doctor to fully remove.",
                        conditions = {
                            { label = "Bleeding", pct = 100, color = "#e05050" },
                        },
                        health = 100,
                        permanent = true,
                        note = "Leaves debuff",
                    },
                }
            },
            {
                title = "Illness & Infection",
                type  = "medicine-grid",
                medicines = {
                    {
                        item = "consumable_med_antibiotic",
                        name = "Antibiotic",
                        desc = "Powerful medicine that fights bacterial infections and illness.",
                        conditions = {
                            { label = "Cold",         pct = 100, color = "#60b8d0" },
                            { label = "Wound Infect", pct = 80,  color = "#e08030" },
                            { label = "Dysentery",    pct = 50,  color = "#a08030" },
                            { label = "Cholera",      pct = 40,  color = "#50c8a0" },
                            { label = "Typhoid",      pct = 50,  color = "#c0a050" },
                            { label = "Yellow Fever", pct = 40,  color = "#d0c040" },
                            { label = "Influenza",    pct = 80,  color = "#80b0d0" },
                            { label = "Tuberculosis", pct = 5,   color = "#a09090" },
                        },
                        health = 200,
                    },
                    {
                        item = "consumable_med_antipoison",
                        name = "Antidote",
                        desc = "Neutralises snake venom and other poisons in the bloodstream.",
                        conditions = {
                            { label = "Snake Bite", pct = 100, color = "#60c060" },
                        },
                        health = 0,
                    },
                    {
                        item = "herbal_medicine",
                        name = "Herbal Medicine",
                        desc = "Natural remedy brewed from herbs. Treats a range of ailments.",
                        conditions = {
                            { label = "Cold",         pct = 50, color = "#60b8d0" },
                            { label = "Dysentery",    pct = 80, color = "#a08030" },
                            { label = "Wound Infect", pct = 30, color = "#e08030" },
                            { label = "Cholera",      pct = 20, color = "#50c8a0" },
                            { label = "Typhoid",      pct = 20, color = "#c0a050" },
                            { label = "Yellow Fever", pct = 20, color = "#d0c040" },
                            { label = "Influenza",    pct = 60, color = "#80b0d0" },
                        },
                        health = 150,
                    },
                    {
                        item = "consumable_medicine",
                        name = "Medicine",
                        desc = "General-purpose medicine providing mild symptomatic relief.",
                        conditions = {
                            { label = "Cold",         pct = 20, color = "#60b8d0" },
                            { label = "Wound Infect", pct = 10, color = "#e08030" },
                        },
                        health = 100,
                    },
                    {
                        item = "insect_medicine",
                        name = "Insect Bite Remedy",
                        desc = "Targeted treatment for insect-borne diseases such as malaria and yellow fever.",
                        conditions = {
                            { label = "Malaria",      pct = 80, color = "#a060c0" },
                            { label = "Yellow Fever", pct = 50, color = "#d0c040" },
                        },
                        health = 100,
                    },
                    {
                        item = "morphine",
                        name = "Morphine",
                        desc = "Powerful opiate administered by Doctors for severe infections and trauma.",
                        conditions = {
                            { label = "Wound Infect", pct = 100, color = "#e08030" },
                            { label = "Cold",         pct = 30,  color = "#60b8d0" },
                            { label = "Malaria",      pct = 50,  color = "#a060c0" },
                            { label = "Typhoid",      pct = 40,  color = "#c0a050" },
                        },
                        health = 400,
                        doctorOnly = true,
                    },
                }
            },
            {
                title = "Tonics & Restoratives",
                type  = "medicine-grid",
                medicines = {
                    {
                        item = "herbal_tonic",
                        name = "Herbal Tonic",
                        desc = "Light herbal brew that eases cold symptoms and mild heat sickness.",
                        conditions = {
                            { label = "Cold",       pct = 30, color = "#60b8d0" },
                            { label = "Heat Stroke", pct = 30, color = "#e06030" },
                        },
                        health = 150,
                    },
                    {
                        item = "consumable_med_tonic",
                        name = "Health Tonic",
                        desc = "A mild restorative tonic that promotes gentle healing.",
                        conditions = {
                            { label = "Cold", pct = 15, color = "#60b8d0" },
                        },
                        health = 150,
                    },
                    {
                        item = "consumable_med_tonic_potent",
                        name = "Potent Health Tonic",
                        desc = "Stronger version of the health tonic with better cold treatment.",
                        conditions = {
                            { label = "Cold", pct = 30, color = "#60b8d0" },
                        },
                        health = 250,
                    },
                    {
                        item = "consumable_med_special_tonic",
                        name = "Special Health Tonic",
                        desc = "Potent compound tonic that treats multiple serious conditions at once.",
                        conditions = {
                            { label = "Cold",         pct = 50, color = "#60b8d0" },
                            { label = "Wound Infect", pct = 30, color = "#e08030" },
                            { label = "Heat Stroke",  pct = 50, color = "#e06030" },
                        },
                        health = 400,
                    },
                    {
                        item = "consumable_med_restorative",
                        name = "Restorative",
                        desc = "Cooling blend that helps the body recover from heat sickness.",
                        conditions = {
                            { label = "Heat Stroke", pct = 50, color = "#e06030" },
                        },
                        health = 200,
                    },
                    {
                        item = "consumable_med_restorative_potent",
                        name = "Potent Restorative",
                        desc = "Fully cures heat stroke and significantly restores vitality.",
                        conditions = {
                            { label = "Heat Stroke", pct = 100, color = "#e06030" },
                        },
                        health = 300,
                    },
                    {
                        item = "stimulant_tonic",
                        name = "Stimulant Tonic",
                        desc = "Energizing tonic that combats heat sickness and restores alertness.",
                        conditions = {
                            { label = "Heat Stroke", pct = 30, color = "#e06030" },
                            { label = "Cold",        pct = 10, color = "#60b8d0" },
                        },
                        health = 200,
                    },
                    {
                        item = "consumable_med_valerian_root",
                        name = "Valerian Root Tonic",
                        desc = "Calming tonic made from Valerian Root. Mild cold and heat relief.",
                        conditions = {
                            { label = "Cold",       pct = 20, color = "#60b8d0" },
                            { label = "Heat Stroke", pct = 10, color = "#e06030" },
                        },
                        health = 120,
                    },
                    {
                        item = "consumable_med_snake_oil",
                        name = "Snake Oil",
                        desc = "Old folk remedy. Mild effect — better than nothing.",
                        conditions = {
                            { label = "Cold", pct = 10, color = "#60b8d0" },
                        },
                        health = 80,
                    },
                    {
                        item = "consumable_med_snake_oil_potent",
                        name = "Potent Snake Oil",
                        desc = "A stronger brew of the classic remedy with noticeable benefit.",
                        conditions = {
                            { label = "Cold",         pct = 25, color = "#60b8d0" },
                            { label = "Wound Infect", pct = 10, color = "#e08030" },
                        },
                        health = 150,
                    },
                }
            },
            {
                title = "Salves, Splints & Smelling Salts",
                type  = "medicine-grid",
                medicines = {
                    {
                        item = "consumable_salve_creekplum",
                        name = "Creekplum Salve",
                        desc = "Light salve applied to wounds. Also heals specific body-part injuries.",
                        conditions = {
                            { label = "Wound Infect", pct = 20, color = "#e08030" },
                        },
                        health = 120,
                        healAmount = 25,
                    },
                    {
                        item = "burn_salve",
                        name = "Burn Salve",
                        desc = "Soothing burn remedy that treats wound infections and body injuries.",
                        conditions = {
                            { label = "Wound Infect", pct = 40, color = "#e08030" },
                        },
                        health = 200,
                        healAmount = 60,
                    },
                    {
                        item = "splint",
                        name = "Splint",
                        desc = "Wooden brace that supports broken bones. Reduces fracture severity by 1.",
                        conditions = {
                            { label = "Broken Bone", pct = 100, color = "#c0a050" },
                        },
                        health = 0,
                        healAmount = 40,
                    },
                    {
                        item = "smelling_salts",
                        name = "Smelling Salts",
                        desc = "Sharp ammonia salts that jolt the senses. Eases concussion and heat.",
                        conditions = {
                            { label = "Heat Stroke", pct = 20, color = "#e06030" },
                        },
                        health = 100,
                    },
                }
            },
            {
                title = "Doctor-Only Premium Items",
                type  = "medicine-grid",
                medicines = {
                    {
                        item = "health_elixir",
                        name = "Health Elixir",
                        desc = "Powerful all-purpose elixir. Treats nearly every major condition at high effectiveness.",
                        conditions = {
                            { label = "Cold",         pct = 80, color = "#60b8d0" },
                            { label = "Wound Infect", pct = 60, color = "#e08030" },
                            { label = "Malaria",      pct = 60, color = "#a060c0" },
                            { label = "Dysentery",    pct = 60, color = "#a08030" },
                            { label = "Heat Stroke",  pct = 60, color = "#e06030" },
                            { label = "Cholera",      pct = 80, color = "#50c8a0" },
                            { label = "Typhoid",      pct = 90, color = "#c0a050" },
                            { label = "Yellow Fever", pct = 80, color = "#d0c040" },
                            { label = "Influenza",    pct = 70, color = "#80b0d0" },
                        },
                        health = 500,
                        doctorOnly = true,
                    },
                }
            },
            {
                title = "Revive Items — Doctor Use Only",
                type  = "medicine-grid",
                medicines = {
                    {
                        item = "syringe",
                        name = "Syringe",
                        desc = "Medical syringe used by Doctors to revive unconscious patients.",
                        conditions = {
                            { label = "Revives Player", pct = 100, color = "#7ec8a2" },
                        },
                        health = 200,
                        doctorOnly = true,
                    },
                    {
                        item = "smellingsalt_lavenderstrawberry",
                        name = "Lavender Smelling Salts",
                        desc = "Aromatic smelling salts used by Doctors as a gentler revival method.",
                        conditions = {
                            { label = "Revives Player", pct = 100, color = "#7ec8a2" },
                        },
                        health = 150,
                        doctorOnly = true,
                    },
                }
            },
        }
    },
}

return {
	-- Cash
	['money'] = {
		label = 'Money',
	},
	['black_money'] = {
		label = 'Dirty Money',
	},
	-- Card ITEMS
	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},
	['id_card'] = {
        label = 'ID Card',
        weight = 0,
        stack = false,
        close = false,
        consume = 0,
        description = 'A card containing all your information for identification purposes.'
    },
    ['driver_license'] = {
        label = 'Drivers License',
        weight = 0,
        stack = false,
        close = false,
        consume = 0,
        description = 'A license demonstrating your ability to legally operate a vehicle.'
    },
    ['lawyerpass'] = {
        label = 'Lawyer Pass',
        weight = 0,
        stack = false,
        close = false,
        consume = 0,
        description = 'An exclusive pass for lawyers to demonstrate their authorization to represent a client.'
    },
    ['weaponlicense'] = {
        label = 'Weapon License',
        weight = 0,
        stack = false,
        close = false,
        consume = 0,
        description = 'A license permitting the legal ownership and use of weapons.'
    },
    ['visa'] = {
        label = 'Visa Card',
        weight = 0,
        stack = false,
        close = false,
        consume = 0,
        description = 'A Visa card that can be used via ATM.'
    },
    ['mastercard'] = {
        label = 'Master Card',
        weight = 0,
        stack = false,
        close = false,
        consume = 0,
        description = 'A MasterCard that can be used via ATM.'
    },
    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 0,
        close = false,
        consume = 0,
        description = 'A security card. Its purpose and access are undisclosed.'
    },
    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 0,
        close = false,
        consume = 0,
        description = 'A security card. Its purpose and access are undisclosed.'
    },
	-- Eat ITEMS
	['tosti'] = {
        label = 'Grilled Cheese Sandwich',
        weight = 200,
        description = 'A delicious sandwich made with melted cheese between toasted bread slices.'
    },
    ['twerks_candy'] = {
        label = 'Twerks',
        weight = 100,
        description = 'Sweet and tangy candies that will make your taste buds dance.'
    },
    ['snikkel_candy'] = {
        label = 'Snikkel',
        weight = 100,
        description = 'Indulge in these delightful candies that will satisfy your sweet cravings.'
    },
    ['sandwich'] = {
        label = 'Sandwich',
        weight = 200,
        description = 'A classic combination of fresh ingredients between two slices of bread.'
    },
	-- Drink ITEMS
	['water_bottle'] = {
        label = 'Bottle of Water',
        weight = 500,
        description = 'Stay hydrated with this refreshing bottle of water.'
    },
    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
        description = 'Start your day right with a cup of freshly brewed coffee.'
    },
    ['kurkakola'] = {
        label = 'Cola',
        weight = 500,
        description = 'Quench your thirst with the classic taste of cola.'
    },
	-- Alcohol
	['beer'] = {
        label = 'Beer',
        weight = 500,
        description = 'Nothing like a good cold beer!'
    },
    ['whiskey'] = {
        label = 'Whiskey',
        weight = 500,
        description = 'Savor the rich flavor of whiskey, perfect for relaxing after a long day.'
    },
    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
        description = 'Enjoy the smooth taste of vodka, ideal for mixing in cocktails or sipping neat.'
    },
    ['grape'] = {
        label = 'Grape',
        weight = 100,
        close = false,
        description = 'Indulge in the sweet and juicy flavor of grapes.'
    },
    ['wine'] = {
        label = 'Wine',
        weight = 300,
        close = false,
        description = 'Sip on some fine wine to elevate any occasion.'
    },
    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
        close = false,
        description = 'Refresh yourself with the healthy and delicious taste of grape juice.'
    },
	-- Drugs
	['joint'] = {
        label = 'Joint',
        weight = 0,
        description = 'A rolled cigarette containing cannabis, ready to be smoked for recreational purposes.'
    },
    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 0,
        description = 'A small bag containing cocaine powder, used for recreational purposes.'
    },
    ['crack_baggy'] = {
        label = 'Bag of Crack',
        weight = 0,
        description = 'A small bag containing crack cocaine, a highly addictive and potent form of the drug.'
    },
    ['xtcbaggy'] = {
        label = 'Bag of XTC',
        weight = 0,
        description = 'A baggie containing XTC pills, also known as ecstasy, a popular party drug.'
    },
    ['weed_brick'] = {
        label = 'Weed Brick',
        weight = 1000,
        description = 'A large brick of marijuana, typically sold in bulk to customers.'
    },
    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 1000,
        stack = false,
        description = 'A large brick of cocaine, primarily used for distribution in the drug trade.'
    },
    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 350,
        stack = false,
        description = 'A smaller package of cocaine, commonly used for individual sales or transactions.'
    },
    ['oxy'] = {
        label = 'Prescription Oxy',
        weight = 0,
        description = 'A prescription pill of Oxycodone, a potent opioid pain medication.'
    },
    ['meth'] = {
        label = 'Meth',
        weight = 100,
        description = 'A baggie containing methamphetamine, a highly addictive and dangerous stimulant drug.'
    },
    ['rolling_paper'] = {
        label = 'Rolling Paper',
        weight = 0,
        description = 'Thin papers used for rolling tobacco or cannabis into cigarettes or joints.'
    },
	-- Seed And Weed
	['weed_white-widow'] = {
        label = 'White Widow 2g',
        weight = 200,
        close = false,
        description = '2 grams of White Widow, known for its potent and relaxing effects.'
    },
    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
        close = false,
        description = '2 grams of Skunk, a classic strain with a strong and pungent aroma.'
    },
    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
        close = false,
        description = '2 grams of Purple Haze, famed for its euphoric and psychedelic properties.'
    },
    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
        close = false,
        description = '2 grams of OG Kush, a legendary strain known for its relaxing and uplifting effects.'
    },
    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
        close = false,
        description = '2 grams of Amnesia, prized for its potent and cerebral high.'
    },
    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
        close = false,
        description = '2 grams of AK47, a versatile strain known for its uplifting and mellow effects.'
    },
    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 0,
        close = false,
        description = 'A seed of White Widow, ready to be planted and cultivated.'
    },
    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 0,
        description = 'A seed of Skunk, perfect for growing your own supply.'
    },
    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 0,
        description = 'A seed of Purple Haze, ideal for starting your cannabis garden.'
    },
    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 0,
        description = 'A seed of OG Kush, ready to be planted and nurtured.'
    },
    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        weight = 0,
        description = 'A seed of Amnesia, suitable for cultivation and growth.'
    },
    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 0,
        description = 'A seed of AK47, waiting to be planted and tended.'
    },
    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
        description = 'A small empty bag, once holding a stash of cannabis.'
    },
    ['weed_nutrition'] = {
        label = 'Plant Fertilizer',
        weight = 2000,
        description = 'Nutrient-rich fertilizer for promoting healthy growth in cannabis plants.'
    },
	-- Material
	['plastic'] = {
        label = 'Plastic',
        weight = 100,
        close = false,
        description = 'Versatile synthetic material often used in manufacturing and packaging.'
    },
    ['metalscrap'] = {
        label = 'Scrap Metal',
        weight = 100,
        close = false,
        description = 'Assorted pieces of metal that can be recycled or repurposed.'
    },
    ['copper'] = {
        label = 'Copper',
        weight = 100,
        close = false,
        description = 'Valuable metal prized for its conductivity and corrosion resistance.'
    },
    ['aluminum'] = {
        label = 'Aluminium',
        weight = 100,
        close = false,
        description = 'Lightweight metal widely used in construction, transportation, and packaging.'
    },
    ['aluminumoxide'] = {
        label = 'Aluminium Powder',
        weight = 100,
        close = false,
        description = 'Fine powder used in various industrial processes such as metallurgy and ceramics.'
    },
    ['iron'] = {
        label = 'Iron',
        weight = 100,
        close = false,
        description = 'Durable metal with numerous applications in construction, manufacturing, and engineering.'
    },
    ['ironoxide'] = {
        label = 'Iron Powder',
        weight = 100,
        close = false,
        description = 'Fine powder used in metallurgy, chemical reactions, and as a pigment.'
    },
    ['steel'] = {
        label = 'Steel',
        weight = 100,
        close = false,
        description = 'Strong and versatile alloy of iron and carbon used in construction, manufacturing, and transportation.'
    },
    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
        close = false,
        description = 'Elastic polymer commonly used in tires, seals, and various other products.'
    },
    ['glass'] = {
        label = 'Glass',
        weight = 100,
        close = false,
        description = 'Transparent material made by cooling and solidifying molten silica, often used in windows, bottles, and lenses.'
    },
	-- Tools
	['lockpick'] = {
        label = 'Lockpick',
        weight = 300,
        description = 'A versatile tool for bypassing locks, handy for locksmiths and adventurers alike.'
    },
    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
        description = 'An upgraded version of the standard lockpick, designed for more complex locks and situations.'
    },
    ['electronickit'] = {
        label = 'Electronic Kit',
        weight = 100,
        description = 'A beginner\'s kit for electronic enthusiasts, perfect for tinkering with circuits and gadgets.'
    },
    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 0,
        description = 'Software tool used for hacking into electronic systems and bypassing security measures.'
    },
    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
        description = 'Highly reactive mixture used for incendiary purposes, capable of melting through various metals.'
    },
    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 0,
        description = 'A USB device loaded with malicious software, used for infiltrating and compromising computer systems.'
    },
    ['screwdriverset'] = {
        label = 'Toolkit',
        weight = 1000,
        close = false,
        description = 'A comprehensive set of screwdrivers for various types of screws, essential for DIY projects and repairs.'
    },
    ['drill'] = {
        label = 'Drill',
        weight = 20000,
        close = false,
        description = 'A powerful handheld tool used for drilling holes in various materials, indispensable for construction and woodworking.'
    },
	-- Vehicle Tools
	['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
        description = 'Press the gas pedal and feel the exhilarating rush of speed with a shot of nitrous oxide!'
    },
    ['repairkit'] = {
        label = 'Repairkit',
        weight = 2500,
        description = 'A comprehensive toolbox equipped with everything you need to perform repairs on your vehicle.'
    },
    ['advancedrepairkit'] = {
        label = 'Advanced Repairkit',
        weight = 4000,
        description = 'An upgraded version of the standard repair kit, featuring advanced tools for more complex repairs.'
    },
    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 250,
        description = 'Restore the shine to your vehicle with this cleaning kit, complete with microfiber cloth and soap.'
    },
    ['harness'] = {
        label = 'Race Harness',
        weight = 1000,
        stack = false,
        description = 'Stay securely fastened in your seat during high-speed races with this professional racing harness.'
    },
    ['jerry_can'] = {
        label = 'Jerrycan 20L',
        weight = 20000,
        description = 'A durable canister capable of holding up to 20 liters of fuel, perfect for long journeys or emergencies.'
    },
	-- Medication
    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
        description = 'Administer first aid and stabilize injuries with this comprehensive first aid kit, essential for emergencies.'
    },
    ['bandage'] = {
        label = 'Bandage',
        weight = 0,
        description = 'A simple yet effective bandage for treating minor cuts, scrapes, and wounds.'
    },
    ['ifaks'] = {
        label = 'IFAKs',
        weight = 200,
        description = 'Individual First Aid Kits (IFAKs) designed for immediate medical response in the field, including trauma supplies and stress relief.'
    },
    ['painkillers'] = {
        label = 'Painkillers',
        weight = 0,
        description = 'Relieve moderate to severe pain quickly and effectively with these potent painkillers.'
    },
    ['walkstick'] = {
        label = 'Walking Stick',
        weight = 1000,
        description = 'Sturdy walking stick for stability and support, ideal for hiking or aiding mobility.'
    },
	-- Communication
	['phone'] = {
        label = 'Phone',
        weight = 700,
        stack = false,
        close = false,
        description = 'Stay connected with this sleek and versatile mobile phone.',
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
    },
    ['radio'] = {
        label = 'Radio',
        weight = 2000,
        stack = false,
        description = 'Tune in to broadcasts and communicate with others using this portable radio.'
    },
    ['iphone'] = {
        label = 'iPhone',
        weight = 1000,
        description = 'Experience the pinnacle of smartphone technology with this premium iPhone.'
    },
    ['samsungphone'] = {
        label = 'Samsung S10',
        weight = 1000,
        description = 'Discover the cutting-edge features of the Samsung S10 smartphone.'
    },
    ['laptop'] = {
        label = 'Laptop',
        weight = 4000,
        description = 'Powerful and portable, this laptop is perfect for work or entertainment.'
    },
    ['tablet'] = {
        label = 'Tablet',
        weight = 2000,
        description = 'Enjoy the convenience of a touchscreen interface with this high-performance tablet.'
    },
    ['radioscanner'] = {
        label = 'Radio Scanner',
        weight = 1000,
        description = 'Listen in on police alerts and other transmissions with this handy radio scanner.'
    },
    ['pinger'] = {
        label = 'Pinger',
        weight = 1000,
        description = 'Share your precise location with others using this handy pinger device.'
    },
    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 200,
        stack = false,
        description = 'Store your virtual currency securely with this state-of-the-art crypto stick.'
    },
	-- Theft and Jewelry
	['rolex'] = {
        label = 'Golden Watch',
        weight = 1500,
        description = 'Elegance meets precision with this luxurious golden watch.'
    },
    ['diamond_ring'] = {
        label = 'Diamond Ring',
        weight = 1500,
        description = 'Celebrate special moments with the timeless beauty of this diamond ring.'
    },
    ['diamond'] = {
        label = 'Diamond',
        weight = 1000,
        description = 'Capture the brilliance and rarity of a diamond, a symbol of enduring love.'
    },
    ['goldchain'] = {
        label = 'Golden Chain',
        weight = 1500,
        description = 'Make a bold statement with this exquisite golden chain adorning your neck.'
    },
    ['10kgoldchain'] = {
        label = '10k Gold Chain',
        weight = 2000,
        description = 'Add a touch of luxury to your attire with this 10-carat gold chain.'
    },
    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 7000,
        description = 'Own a piece of pure wealth with this solid gold bar.'
    },
    ['small_tv'] = {
        label = 'Small TV',
        weight = 30000,
        stack = false,
        description = 'Enjoy your favorite shows and movies on this compact yet feature-packed television.'
    },
    ['toaster'] = {
        label = 'Toaster',
        weight = 18000,
        stack = false,
        description = 'Start your day right with perfectly toasted bread from this reliable toaster.'
    },
    ['microwave'] = {
        label = 'Microwave',
        weight = 46000,
        stack = false,
        description = 'Heat up meals quickly and efficiently with this essential kitchen appliance.'
    },
	-- Police Tools
	['armor'] = {
        label = 'Armor',
        weight = 5000,
        description = 'Equip yourself with this protective armor to enhance your defense against threats.'
    },
    ['heavyarmor'] = {
        label = 'Heavy Armor',
        weight = 5000,
        description = 'Enhanced protection for those facing the toughest challenges.'
    },
    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 100,
        description = 'Maintain order and control with these sturdy handcuffs.'
    },
    ['police_stormram'] = {
        label = 'Stormram',
        weight = 18000,
        description = 'Break through barriers and obstacles with this heavy-duty stormram.'
    },
    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 0,
        close = false,
        description = 'Essential for preserving evidence at crime scenes, ready to be filled with crucial clues.'
    },
    ['filled_evidence_bag'] = {
        label = 'Evidence Bag',
        weight = 200,
        stack = false,
        close = false,
        description = 'Contains vital evidence that could help solve a criminal case.'
    },
	-- Fireworks
    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
        description = 'Light up the sky with colorful explosions using the 2Brothers firework.'
    },
    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
        description = 'Experience a dazzling display of lights and sounds with the Poppelers firework.'
    },
    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
        description = 'Create stunning visual effects with the WipeOut firework.'
    },
    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
        description = 'Enjoy the graceful cascade of colors reminiscent of a weeping willow tree with this firework.'
    },
	-- Sea Tools
    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
        description = 'Also known as pillar coral, this species adds beauty to underwater landscapes.'
    },
    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 1000,
        description = 'Also known as black corals or thorn corals, this species thrives in deep ocean environments.'
    },
    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 30000,
        stack = false,
        description = 'Equip yourself with this diving gear, including an oxygen tank and a rebreather, for extended underwater exploration.'
    },
    ['diving_fill'] = {
        label = 'Diving Tube',
        weight = 3000,
        stack = false,
        description = 'Essential for deep-sea dives, this diving tube ensures a steady supply of oxygen.'
    },
	-- Misc
    ['casinochips'] = {
        label = 'Casino Chips',
        weight = 0,
        close = false,
        description = 'Join the excitement of casino gambling with these colorful and valuable chips.'
    },
    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
        stack = false,
        close = false,
        description = 'Useful for jotting down quick reminders or messages, these sticky notes come in handy.'
    },
    ['moneybag'] = {
        label = 'Money Bag',
        weight = 0,
        stack = false,
        description = 'Keep your cash secure and organized in this sturdy money bag.'
    },
    ['parachute'] = {
        label = 'Parachute',
        weight = 30000,
        stack = false,
        description = 'Leap into the sky and experience the thrill of freefalling with this reliable parachute.'
    },
    ['binoculars'] = {
        label = 'Binoculars',
        weight = 600,
        description = 'Zoom in on distant objects and landscapes with these powerful binoculars.'
    },
    ['lighter'] = {
        label = 'Lighter',
        weight = 0,
        description = 'Light up the night or start a cozy fire with this trusty lighter.'
    },
    ['certificate'] = {
        label = 'Certificate',
        weight = 0,
        description = 'Official documentation that certifies ownership or accomplishment.'
    },
    ['markedbills'] = {
        label = 'Marked Money',
        weight = 1000,
        stack = false,
        description = 'Money that has been marked for tracking or identification purposes.'
    },
    ['labkey'] = {
        label = 'Key',
        weight = 500,
        stack = false,
        description = 'A key that unlocks access to specific areas or items, such as a laboratory.'
    },
    ['printerdocument'] = {
        label = 'Document',
        weight = 500,
        stack = false,
        description = 'A printed document containing valuable information or records.'
    },
	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},
	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},
	['garbage'] = {
		label = 'Garbage',
	},
}

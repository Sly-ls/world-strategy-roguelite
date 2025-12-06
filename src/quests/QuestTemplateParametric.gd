# res://src/quests/templates/QuestTemplateParametric.gd
extends QuestTemplate
class_name QuestTemplateParametric

## Template de quête paramétrique avec slots variables
## PALIER 2 : Système de templates réutilisables

# ========================================
# SLOTS PARAMÉTRIQUES
# ========================================

@export var title_template: String = ""  ## Ex: "Défendre {city} contre {enemy}"
@export var description_template: String = ""  ## Ex: "Les {enemy} attaquent {city}..."

@export var parameter_slots: Dictionary = {}  ## Slots et leurs valeurs possibles
# Exemple: {
#   "city": ["Fortress", "Haven", "Bastion"],
#   "enemy": ["Orcs", "Bandits", "Morts-vivants"],
#   "reward_gold": [50, 100, 150]
# }

# ========================================
# GÉNÉRATION
# ========================================

func generate_instance(seed: int) -> QuestTemplate:
	"""Génère une instance concrète du template avec valeurs aléatoires"""
	
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	
	# Créer une copie du template
	var instance := QuestTemplate.new()
	
	# Copier les propriétés de base
	instance.id = id + "_" + str(seed)
	instance.category = category
	instance.tier = tier
	instance.objective_type = objective_type
	instance.objective_count = objective_count
	instance.expires_in_days = expires_in_days
	
	# Générer les valeurs des slots
	var slot_values := _generate_slot_values(rng)
	
	# Remplir les templates
	instance.title = _fill_template(title_template, slot_values)
	instance.description = _fill_template(description_template, slot_values)
	instance.objective_target = _fill_template(objective_target, slot_values)
	
	# Générer les récompenses dynamiques
	instance.rewards = _generate_dynamic_rewards(slot_values, rng)
	
	# Copier les tags et conditions
	instance.required_player_tags = required_player_tags.duplicate()
	instance.adds_player_tags = adds_player_tags.duplicate()
	
	return instance

func _generate_slot_values(rng: RandomNumberGenerator) -> Dictionary:
	"""Génère des valeurs aléatoires pour chaque slot"""
	var values := {}
	
	for slot_name in parameter_slots:
		var possible_values: Array = parameter_slots[slot_name]
		if possible_values.is_empty():
			continue
		
		var index := rng.randi_range(0, possible_values.size() - 1)
		values[slot_name] = possible_values[index]
	
	return values

func _fill_template(template_str: String, values: Dictionary) -> String:
	"""Remplace les {slots} par leurs valeurs"""
	var result := template_str
	
	for slot_name in values:
		var placeholder := "{%s}" % slot_name
		result = result.replace(placeholder, str(values[slot_name]))
	
	return result

func _generate_dynamic_rewards(slot_values: Dictionary, rng: RandomNumberGenerator) -> Array[QuestReward]:
	"""Génère des récompenses basées sur les paramètres"""
	var dynamic_rewards: Array[QuestReward] = []
	
	# Copier les récompenses de base
	for reward in rewards:
		var new_reward := QuestReward.new()
		new_reward.type = reward.type
		new_reward.amount = reward.amount
		new_reward.target_id = reward.target_id
		
		# Ajuster montant si slot paramétrique
		if slot_values.has("reward_gold") and reward.type == QuestTypes.RewardType.GOLD:
			new_reward.amount = slot_values["reward_gold"]
		
		if slot_values.has("reward_food") and reward.type == QuestTypes.RewardType.FOOD:
			new_reward.amount = slot_values["reward_food"]
		
		dynamic_rewards.append(new_reward)
	
	return dynamic_rewards

# ========================================
# VALIDATION
# ========================================

func validate() -> bool:
	"""Vérifie que le template est valide"""
	if title_template.is_empty():
		push_error("QuestTemplateParametric: title_template is empty")
		return false
	
	if description_template.is_empty():
		push_error("QuestTemplateParametric: description_template is empty")
		return false
	
	# Vérifier que tous les slots du template existent
	var slots_in_title := _extract_slots(title_template)
	var slots_in_desc := _extract_slots(description_template)
	
	for slot in slots_in_title:
		if not parameter_slots.has(slot):
			push_error("QuestTemplateParametric: Missing slot '%s' in parameter_slots" % slot)
			return false
	
	for slot in slots_in_desc:
		if not parameter_slots.has(slot):
			push_error("QuestTemplateParametric: Missing slot '%s' in parameter_slots" % slot)
			return false
	
	return true

func _extract_slots(template_str: String) -> Array[String]:
	"""Extrait les noms de slots d'un template"""
	var slots: Array[String] = []
	var regex := RegEx.new()
	regex.compile("\\{([^}]+)\\}")
	
	for result in regex.search_all(template_str):
		slots.append(result.get_string(1))
	
	return slots

# ========================================
# HELPERS
# ========================================

func get_all_slots() -> Array[String]:
	"""Retourne tous les slots définis"""
	var slots: Array[String] = []
	for slot_name in parameter_slots:
		slots.append(slot_name)
	return slots

func get_slot_values(slot_name: String) -> Array:
	"""Retourne les valeurs possibles pour un slot"""
	return parameter_slots.get(slot_name, [])

func add_slot(slot_name: String, values: Array) -> void:
	"""Ajoute un nouveau slot"""
	parameter_slots[slot_name] = values

func remove_slot(slot_name: String) -> void:
	"""Retire un slot"""
	parameter_slots.erase(slot_name)

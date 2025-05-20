export type LimbInfo = {
	coordinate_frame0: CFrame,
	coordinate_frame1: CFrame,

	-- TEMP
	priority: number,
	transform: CFrame,

	name: string,
	derived: { LimbInfo },
}

export type Identity = {
	root: LimbInfo,
	flattened: { LimbInfo },
	limbs_by_name: { [string]: LimbInfo },

	result: { [string]: CFrame },
}

type InputNode = {
	coordinate_frame0: CFrame,
	coordinate_frame1: CFrame,

	children: {
		[string]: InputNode,
	},
}

export type InputRootNode = InputNode & {
	root_name: string,
}

local function process_input_node(
	limb_info_array: { LimbInfo },
	limbs_by_name: { [string]: LimbInfo },
	result: { [string]: CFrame },
	name: string,
	node: InputNode
): LimbInfo
	local node_children = {}

	for child_name, child_node in node.children do
		table.insert(
			node_children,
			process_input_node(limb_info_array, limbs_by_name, result, child_name, child_node)
		)

		result[child_name] = CFrame.identity
	end

	local this_node = {
		name = name,

		coordinate_frame0 = node.coordinate_frame0,
		coordinate_frame1 = node.coordinate_frame1:Inverse(),

		priority = 0,
		transform = node.coordinate_frame1,

		derived = node_children,
	}
	table.insert(limb_info_array, this_node)
	limbs_by_name[name] = this_node

	return this_node
end

local function create_rig(input_rig: InputRootNode): Identity
	local limb_info_array: { LimbInfo } = {}
	local limbs_by_name: { [string]: LimbInfo } = {}
	local result_template: { [string]: CFrame } = {}

	local root = process_input_node(
		limb_info_array,
		limbs_by_name,
		result_template,
		input_rig.root_name,
		input_rig
	)

	return {
		root = root,
		flattened = limb_info_array,
		limbs_by_name = limbs_by_name,

		result = result_template,
	}
end

return {
	create_rig = create_rig,
}

note
	description: "[
		Message in AI conversation with role and content.
		
		Represents a single message in a conversation with an AI provider.
		Each message has a role (system, user, or assistant) and text content.
		
		Role Semantics:
		- system: Instructions/context for the AI (e.g., "You are a helpful assistant")
		- user: Messages from the human user
		- assistant: Messages from the AI assistant (for multi-turn conversations)
		
		Design by Contract:
		- Role must always be valid (system/user/assistant)
		- Content must never be empty
		- All creation routines enforce these constraints
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	AI_MESSAGE

create
	make,
	make_system,
	make_user,
	make_assistant

feature {NONE} -- Initialization

	make (a_role: STRING_8; a_content: STRING_32)
			-- Create message with `a_role' and `a_content'
		require
			role_valid: valid_role (a_role)
			role_not_empty: not a_role.is_empty
			content_attached: a_content /= Void
			content_not_empty: not a_content.is_empty
			content_reasonable_length: a_content.count <= Max_reasonable_content_length
		do
			role := a_role
			content := a_content
		ensure
			role_set: role = a_role
			content_set: content = a_content
			role_still_valid: valid_role (role)
		end

	make_system (a_content: STRING_32)
			-- Create system message with `a_content'
			-- System messages provide instructions/context to the AI
		require
			content_attached: a_content /= Void
			content_not_empty: not a_content.is_empty
			content_reasonable_length: a_content.count <= Max_reasonable_content_length
		do
			make (Role_system, a_content)
		ensure
			is_system: is_system
			content_set: content = a_content
		end

	make_user (a_content: STRING_32)
			-- Create user message with `a_content'
			-- User messages represent input from the human
		require
			content_attached: a_content /= Void
			content_not_empty: not a_content.is_empty
			content_reasonable_length: a_content.count <= Max_reasonable_content_length
		do
			make (Role_user, a_content)
		ensure
			is_user: is_user
			content_set: content = a_content
		end

	make_assistant (a_content: STRING_32)
			-- Create assistant message with `a_content'
			-- Assistant messages represent AI responses in conversation history
		require
			content_attached: a_content /= Void
			content_not_empty: not a_content.is_empty
			content_reasonable_length: a_content.count <= Max_reasonable_content_length
		do
			make (Role_assistant, a_content)
		ensure
			is_assistant: is_assistant
			content_set: content = a_content
		end

feature -- Access

	role: STRING_8
			-- Message role (system, user, or assistant)

	content: STRING_32
			-- Message content (Unicode text)

feature -- Status report

	is_system: BOOLEAN
			-- Is this a system message?
		do
			Result := role ~ Role_system
		ensure
			definition: Result = (role ~ Role_system)
		end

	is_user: BOOLEAN
			-- Is this a user message?
		do
			Result := role ~ Role_user
		ensure
			definition: Result = (role ~ Role_user)
		end

	is_assistant: BOOLEAN
			-- Is this an assistant message?
		do
			Result := role ~ Role_assistant
		ensure
			definition: Result = (role ~ Role_assistant)
		end

	valid_role (a_role: STRING_8): BOOLEAN
			-- Is `a_role' one of the valid role types?
		require
			role_attached: a_role /= Void
		do
			Result := a_role ~ Role_system or a_role ~ Role_user or a_role ~ Role_assistant
		ensure
			definition: Result = (a_role ~ Role_system or a_role ~ Role_user or a_role ~ Role_assistant)
		end

feature -- Constants

	Role_system: STRING_8 = "system"
			-- System role identifier for AI instructions/context

	Role_user: STRING_8 = "user"
			-- User role identifier for human input

	Role_assistant: STRING_8 = "assistant"
			-- Assistant role identifier for AI responses

	Max_reasonable_content_length: INTEGER = 100_000
			-- Maximum reasonable content length (100KB text)
			-- Protects against accidental massive messages

invariant
	-- Core data integrity
	role_attached: role /= Void
	content_attached: content /= Void

	-- Role validity
	role_not_empty: not role.is_empty
	role_is_valid: valid_role (role)

	-- Content constraints
	content_not_empty: not content.is_empty
	content_reasonable: content.count <= Max_reasonable_content_length

	-- Type consistency: exactly one role is true
	exactly_one_role: 
		(is_system and not is_user and not is_assistant) or
		(not is_system and is_user and not is_assistant) or
		(not is_system and not is_user and is_assistant)

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"
	source: "SIMPLE_AI_CLIENT - Unified AI Provider Library"

end

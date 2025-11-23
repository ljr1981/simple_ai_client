note
	description: "[
		Response from AI provider with text, tokens, and metadata.
		
		Represents the result of an AI provider API call, containing either:
		- Success: response text, model name, token usage
		- Error: error message describing what went wrong
		
		Token Tracking:
		Uses CELL pattern for mutable token counts that can be updated
		after creation. Total tokens = input_tokens + output_tokens.
		
		Design by Contract:
		- Success and error are mutually exclusive states
		- Token counts must always be non-negative
		- Error responses must have error message
		- Success responses must have non-empty model name
		- Provider name is always required
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	AI_RESPONSE

create
	make,
	make_error

feature {NONE} -- Initialization

	make (a_text: STRING_32; a_model: STRING_32; a_provider: STRING_8)
			-- Create successful response with `a_text' from `a_model' via `a_provider'
		require
			text_attached: a_text /= Void
			model_attached: a_model /= Void
			model_not_empty: not a_model.is_empty
			provider_attached: a_provider /= Void
			provider_not_empty: not a_provider.is_empty
		do
			text := a_text
			model := a_model
			provider := a_provider
			is_success := True
			create input_tokens.put (0)
			create output_tokens.put (0)
		ensure
			text_set: text = a_text
			model_set: model = a_model
			provider_set: provider = a_provider
			is_success: is_success
			not_error: not is_error
			no_error_message: error_message = Void
			tokens_initialized: input_tokens.item = 0 and output_tokens.item = 0
		end

	make_error (a_error_message: STRING_32; a_provider: STRING_8)
			-- Create error response with `a_error_message' from `a_provider'
		require
			error_attached: a_error_message /= Void
			error_not_empty: not a_error_message.is_empty
			provider_attached: a_provider /= Void
			provider_not_empty: not a_provider.is_empty
		do
			create text.make_empty
			create model.make_empty
			provider := a_provider
			is_success := False
			error_message := a_error_message
			create input_tokens.put (0)
			create output_tokens.put (0)
		ensure
			not_success: not is_success
			is_error: is_error
			error_set: attached error_message as al_err and then al_err = a_error_message
			provider_set: provider = a_provider
			text_empty: text.is_empty
			model_empty: model.is_empty
			tokens_initialized: input_tokens.item = 0 and output_tokens.item = 0
		end

feature -- Access

	text: STRING_32
			-- Response text (empty for errors)

	model: STRING_32
			-- Model that generated response (empty for errors)

	provider: STRING_8
			-- Provider name (ollama, claude, gemini)

	input_tokens: CELL [INTEGER]
			-- Input token count (mutable via CELL pattern)

	output_tokens: CELL [INTEGER]
			-- Output token count (mutable via CELL pattern)

	error_message: detachable STRING_32
			-- Error message if request failed (Void for success)

feature -- Status report

	is_success: BOOLEAN
			-- Was request successful?

	is_error: BOOLEAN
			-- Did request fail?
		do
			Result := not is_success
		ensure
			definition: Result = not is_success
			mutual_exclusivity: Result = not is_success
		end

feature -- Measurement

	total_tokens: INTEGER
			-- Total tokens used (input + output)
		do
			Result := input_tokens.item + output_tokens.item
		ensure
			non_negative: Result >= 0
			definition: Result = input_tokens.item + output_tokens.item
		end

feature -- Element change

	set_tokens (a_input, a_output: INTEGER)
			-- Set token counts to `a_input' and `a_output'
		require
			input_non_negative: a_input >= 0
			output_non_negative: a_output >= 0
		do
			input_tokens.put (a_input)
			output_tokens.put (a_output)
		ensure
			input_set: input_tokens.item = a_input
			output_set: output_tokens.item = a_output
		end

invariant
	-- Core data integrity
	text_attached: text /= Void
	model_attached: model /= Void
	provider_attached: provider /= Void
	provider_not_empty: not provider.is_empty
	input_tokens_attached: input_tokens /= Void
	output_tokens_attached: output_tokens /= Void

	-- Token constraints
	input_tokens_non_negative: input_tokens.item >= 0
	output_tokens_non_negative: output_tokens.item >= 0
	total_tokens_non_negative: total_tokens >= 0

	-- Success/error mutual exclusivity
	success_xor_error: is_success = not is_error

	-- Error state implications
	error_implies_message: not is_success implies (attached error_message as al_err and then not al_err.is_empty)
	success_implies_no_error_message: is_success implies error_message = Void

	-- Success state implications
	success_implies_model: is_success implies not model.is_empty

note
	copyright: "Copyright (c) 2025, Larry Rix"
	license: "MIT License"
	source: "SIMPLE_AI_CLIENT - Unified AI Provider Library"

end

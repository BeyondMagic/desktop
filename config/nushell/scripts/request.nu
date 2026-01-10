#!/usr/bin/env nu
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2024

const TITLE = "AI Assistant (Mira)"
const IP = '192.168.1.6'
const PORT = 4891
const MAX_TOKENS = -1 # Infinity
const TEMPERATURE = 0.8
const TOP_P = 0.95
const TOP_K = 40
const N = 1 # Use -1 to keep all tokens when exceeded.
const REPEAT_PENALTY = 1.1
const STREAM = true

use std log

# Will chat to LLM and return output.
export def main [
	...message: string, # User prompt.
	--ip: string = $IP, # Internet address to access.
	--port: int = $PORT, # Internet port to access.
	--max_tokens: int = $MAX_TOKENS, # Set the maximum number of tokens to predict when generating text.
	--temperature: float = $TEMPERATURE, # Adjust the randomness of the generated text.
	--top_p: float = $TOP_P, # Limit the next token selection to a subset of tokens with a cumulative probability above a threshold P.
	--top_k: int = $TOP_K, # Limit the next token selection to the K most probable tokens.
	--n_keep: int = $N, # Specify the number of tokens from the prompt to retain when the context size is exceeded and tokens need to be discarded.
	--stream = $STREAM, # It allows receiving each predicted token in real-time instead of waiting for the completion to finish.
	--repeat_penalty: float = $REPEAT_PENALTY, # Control the repetition of token sequences in the generated text.
] -> int {
	if ($message | is-empty) {
		log critical "You have to state some prompt."
		exit 1
	}

	let prompt = ($message | str join ' ')
	do {
		curl ...[
			--silent
			--no-buffer
			--header `accept: application/json`
			--request "POST"
			--header 'Content-Type: application/json'
			--url $'http://($ip):($port)/completion'
			--data-raw $'{
				"prompt": [
					"($prompt)"
				],
				"n_predict": ($max_tokens),
				"temperature": ($temperature),
				"top_p": ($top_p),
				"top_k": ($top_k),
				"n_keep": ($n_keep),
				"stream": ($stream),
				"repeat_penalty": ($repeat_penalty)
			}']
	} | each {|line|
	 	if (not ($line | is-empty)) and ($line | find 'frequency_penalty' | is-empty) and ($line | find 'predicted_per_token_ms' | is-empty) {
			let data = ($line | from json)
			if (not ($data | is-empty)) and ($data | describe) != 'string' {
				^printf "%s" $"($data.data.content)"
			}
	 	}
	}
	print

	const title = $TITLE
	notify-call --urgency critical --app-name $title $title $prompt
}

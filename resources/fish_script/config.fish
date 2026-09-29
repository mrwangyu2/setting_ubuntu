# Fish shell configuration

# Set environment
if test -d /home/frank/.local/node22/bin
    fish_add_path /home/frank/.local/node22/bin
end
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# OpenAI / New-API configuration (DeepSeek Flash V4)
# If OPENAI_API_KEY is not already set in the environment, use default
if not set -q OPENAI_API_BASE
    set -gx OPENAI_API_BASE "http://10.50.0.5:3000/v1"
end
if not set -q OPENAI_BASE_URL
    set -gx OPENAI_BASE_URL "http://10.50.0.5:3000/v1"
end
if not set -q OPENAI_MODEL
    set -gx OPENAI_MODEL "deepseek-v4-flash"
end

# Helper function to chat with DeepSeek from fish terminal
function ask-ai -d "Chat with deepseek-v4-flash via New-API"
    set -l prompt "$argv"
    if test -z "$prompt"
        echo "Usage: ask-ai <prompt>"
        return 1
    end

    curl -s "$OPENAI_BASE_URL/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d (jq -n -c --arg model "$OPENAI_MODEL" --arg content "$prompt" \
            '{model: $model, messages: [{role: "user", content: $content}]}') \
        | jq -r '.choices[0].message.content // .'
end


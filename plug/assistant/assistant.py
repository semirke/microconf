#!/usr/bin/python3

""" OpenAI coding assistant """

# It's a good practice to use os module's os.environ.get() method
# because if we try to just get the value of an environment variable which is not defined,
# it will give a None rather than KeyError Exception
import os
import sys
from openai import OpenAI as OpenAIOfficial

def query_ai(msgs):
    """
    Sends a query to OpenAI.
    Args:
    msgs (list): A list of dict containing the role and content for each message
    Returns:
    An OpenAI response
    """

    # Default value handling can be done directly during environment variable retrieval.
    model = os.getenv("OPENAI_ENGINE", default="gpt-4")

    # Fetching api_key inline could clutter the function.
    # Better to pre-assign it to a variable before using.
    api_key = os.getenv("OPENAI_API_KEY")
    # Check if api_key is present before making a call.
    if not api_key:
        print("API Key Not Found. Please set the OPENAI_API_KEY environment variable.")
        sys.exit(1)

    client = OpenAIOfficial(api_key=api_key)

    # Making an API request to OpenAI.
    # This could fail for various reasons, like network issues,
    # invalid API key, etc. Better to add error handling around it.
    try:
        if model == "gpt-3.5-turbo-instruct":
            prompt = ""
            for msg in msgs:
                prompt += msg["content"] + "\n"
            resp = client.completions.create(model=model, prompt=prompt, stream=False)
            return resp.choices[0].text

        resp = client.chat.completions.create(model=model, messages=msgs, n=1, stream=False)
        return resp.choices[0].message.content

    except Exception as e:
        print(f"Error occurred while making the request with model {model}: {e}")
        sys.exit(1)

# A guard clause to run the following code only if the script is run directly, not imported as a module.
# That is standard Python best practice.
if __name__ == "__main__":

    # Check if filename is provided as a command-line argument.
    if len(sys.argv) < 2:
        print("Please provide the filename as a command-line argument.")
        sys.exit(1)

    with open(sys.argv[1], "r") as f:
        code = f.read()

    prompt = [{"role": "system", "content": "You are a software developer."}]

    # Simplification: You can put all your prompts into the list at once.
    prompt.extend([
        {
            "role": "user",
            "content": (
                "Please review the following program code and add your"
                " recommendations as well. Thank you!"
            ),
        },
        {
            "role": "user",
            "content": (
                "Your review should include syntax checking, linting, spelling errors,"
                " typos and warn on suspicious logic, too."
            ),
        },
        {
            "role": "user",
            "content": (
                "Use in code comments to explain your recommendations in place and also expand the code"
                " with docsstring where you see fit.\n It is very important to make sure the output (print) is not changed."
            ),
        },
        {
            "role": "user",
            "content": (
                "If you find an <openai_generate> tag in a comment, add the requested code below."
            ),
        },
        {"role": "user", "content": "The desired format:```\n{modified code in full}\n```{your explanation under the code}"},
        {"role": "user", "content": "The code:```\n"+ code + "```"},
    ])

    response = query_ai(prompt)

    lines = response.split('\n')
    out = ""
    recom = ""
    started = 0
    for line in lines:
        if started == 0:
            if line[:3] == "```":
                started = 1
                continue
            recom += line + "\n"
        elif started == 1:
            if line[:3] == "```":
                started = 2
                continue
            out += line + "\n"
        else:
            recom += line + "\n"

    out += '"""' + recom + '"""'
    
    print(out)

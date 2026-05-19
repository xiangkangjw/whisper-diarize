Running background agents in production: lessons from Open-Inspect [Register](https://watch.getcontrast.io/register/modal-running-background-agents-in-production-lessons-from-open-inspect?utm_source=modal_announcement_banner)

[All posts](https://modal.com/blog)

[Back](https://modal.com/articles)

Article

August 5, 2025•10 minute read

# The Top Open Source Speech-to-Text (STT) Models in 2025

The world of speech-to-text (STT) is rapidly evolving, with new state-of-the-art models launching every month. Many of these models are open-source and are fairly popular. This article explores some of the top open-source STT models, based on Hugging Face’s trending models and performance benchmarks [from the Open ASR Leaderboard](https://huggingface.co/spaces/hf-audio/open_asr_leaderboard).

| Model | Parameters | Word Error Rate | RTFx | Created By | Released | License |
| --- | --- | --- | --- | --- | --- | --- |
| Canary Qwen 2.5B | 2.5B | 5.63% | 418 | Nvidia | 2025 | Apache 2.0 |
| Granite Speech 3.3 | 8B | 5.85% | 31 | IBM | April 2025 | Apache 2.0 |
| Parakeet TDT 0.6B V2 | 600M | 6.05% | 3386 | Nvidia | May 2025 | CC-BY-4.0 |
| Whisper Large V3 Turbo <br> ( [deploy on Modal](https://modal.com/docs/examples/batched_whisper)) | 809M | 10%-12% | 216 | OpenAI | October 2024 | MIT |
| Kyutai 2.6B <br> ( [deploy on Modal](https://modal.com/docs/examples/streaming_kyutai_stt)) | 2.6B | 6.4% | 88 | Moshi | September 2024 | CC-BY-4.0 |

For a real-world comparison, check out our [fast, cheap batch transcription](https://modal.com/blog/fast-cheap-batch-transcription) blog post, where we transcribed a week of audio in one minute for less than $1 using Parakeet and Canary.

## How should you think about rankings?

While the Hugging Face trending models leaderboard is a rough indication of popularity, it does not prove that a certain model is better than others for your use case. For speech-to-text models, you should consider multiple factors:

1. **Accuracy**. Some models have better accuracy (represented as a lower Word Error Rate, or WER for short). These models might be preferred for applications that have less tolerance for errors, such as phone tree systems, doctor-patient transcription applications, or court documentation tools.
2. **Language Needs**. Many models are designed for English or other major languages like Mandarin or Spanish. If you need a speech-to-text model for a less common language, there might be a language-specific model that is more performant.
3. **Costs**. Some models cost more than others to run. Speech can be expensive to process given its rich data format. Larger models might be more accurate, but could incur higher costs.
4. **Throughput**. Throughput matters to applications that are processed recorded audio, where lengthy audios might take considerably longer on slower models than others. Speed is measured by a model’s RTFx metric, which is discussed in detail below.
5. **Latency**. Latency measures how long it takes for a model to finish producing output tokens after the last chunk of audio is submitted. If your task requires near real-time speech-to-text transcription, such as phone tree software, then a model with low latency might be preferred over a model with higher accuracy.
6. **Developer**. Many models are integrated with other AI models like LLMs. For example, OpenAI developers include Whisper but also GPT-4o, a leading LLM. For some organizations, choosing a model from the same developer may be better for better aligned integrations, pricing (when using managed solutions), and support.

A major benefit of open-source models is that they’re free to try out (minus compute costs). The best way to make an informed decision is to evaluate your use case with different models. These test cases should use real-world or realistic data. This will provide more accurate results—for example, the vocabulary of your average users might impact the word error rate for different models differently.

## What are common metrics relevant to comparing STT models?

There are three common statistics that are used to measure STT models. Understanding these metrics will enable you to better understand the spec sheets of each model.

### What is Word Error Rate (WER)?

Word Error Rate, or WER, is a measure of accuracy. Specifically, WER measures the percentage of words that were incorrectly transcribed by the STT model. Specifically, WER is a measure of the proportional number of substitutions (wrong word used), deletions (extra word), and insertions (missed word) needed for an STT output to be considered perfectly accurate.

Notably, WER is a crude measure of accuracy. For example, mistaking “their” and “there” might be considered trivial in many applications where the user might be less discerning of incorrect homonyms. However, mistaking “thirteen” and “thirty” could be considered a serious mistake, especially in applications where precision matters (e.g., medical transcription services). Some models will rate themselves using a weighted WER, where different mistakes are assigned different weights. Additionally, some models might make substitutions, deletions, or insertions at varying rates. However, WER is a good way of comparing models in a vacuum with no specific use case in mind.

### What is Real Time Factor EXpressed (RTFx)?

RTFx is a measure of _throughput_, as it measures how many seconds of audio an STT system can process per second of compute time. \*\*\*\*Mathematically, `RTFX = audio duration / processing time`. Lower RTFX means slower processing.

Notably, RTFx is _not_ a measure of latency. This is best illustrated in how RTFx impacts applications processing recorded speech vs real-time speech. For recorded speech, RTFx matters because it determines how long a computer needs to work to produce a transcription. For example, a 20-minute call recorded might be transcribed in 5 seconds vs 50 minutes depending on the RTFx metric. However, for real-time audio, such as a live call transcription, the RTFx is _capped_ at 1.0 because audio is only made available at the rate at which the audio is produced. For streamed audio, RTFx doesn’t matter, but latency _does_.

### What is Latency?

Latency is a measure of how fast a model finishes outputting text tokens after the model receives the last chunk of audio. For recorded speech, latency often doesn’t matter because audio is immediately available to the model, and the models can be 10-100x different in computation speed (measured by RTFx). For real-time speech, latency is the _only_ speed metric that matters because the RTFx is capped at 1.0, and only latency impacts how fast the audio transcription is available.

Latency is particularly important to applications that pass a transcription into an LLM, where the LLM needs the full context of the transcription to begin processing it. However, latency isn’t typically stressed by most models for two reasons: (i) research papers use popular datasets like AMI or Earnings22 to test models where only RTFx is measured as data isn’t streamed, and (ii) in many real-time audio scenarios, another AI process like an Large Language Model (LLM) or Text-to-Speech model (TTS) serves as the latency bottleneck over the STT model.

### What are Parameters?

Parameters, often listed in the _billions_ in a model’s name (e.g. Parakeet TDT 0.6B), are the internal numerical values (weights and biases) that the model learns during training to make predictions. More parameters can capture more complex patterns, but take longer to train and often require more compute and memory at runtime. Applications might opt for a model with lower parameters if they are operating on a memory and compute-conscious device, such as a wearable or sensor.

## The Best Speech-to-Text Models in 2025

Now, let’s visit the best speech-to-text (STT) models in 2025.

## Canary Qwen 2.5B

Canary Qwen 2.5B is an STT model developed by Nvidia. Canary Qwen is considered a state-of-the-art model for its low error rate, blazing-fast speed, massive training corpus, and hybrid architecture.

[Canary Qwen 2.5B](https://huggingface.co/nvidia/canary-qwen-2.5b) currently tops the Hugging Face Open ASR leaderboard with a 5.63% word error rate. What sets Canary apart is its new hybrid architecture that combines automatic speech recognition (ASR) with large language model (LLM) capabilities. This makes Canary Qwen 2.5B the first open-source Speech-Augmented Language Model (SALM). At 234,000 hours of English speech training data, this model was trained on almost three times more data than its predecessor, Canary 1B.

Canary Qwen has an RTFx score of 418, meaning that it can process audio 418 times faster than real-time. This is reasonably fast for most industry use cases, but other models, such as Parakeet TDT, do maintain RTFx scores of nearly 10x. Accordingly, Canary Qwen could be considered an accuracy-focused model with acceptable speed.

### What are some popular iterations of Nvidia’s Canary Model?

Canary Qwen 2.5B is the latest in a family of Nvidia Canary models. It’s also worth taking a look at the previous two versions.

[Original Canary-1B](https://huggingface.co/nvidia/canary-1b) (April 2024): This multilingual model supports English, German, French, and Spanish with bidirectional translation capabilities. It was trained on 85,000 hours of speech data and achieved a 6.67% word error rate on the HuggingFace Open ASR Leaderboard. This means it outperformed similarly sized models, such as Whisper-large-v3, despite using significantly less training data.

[Canary-1B-Flash](https://huggingface.co/nvidia/canary-1b-flash) (March 2025): This is an optimization-focused variant of Canary-1B featuring 32 encoder layers and 4 decoder layers that prioritizes inference speed while maintaining exceptional accuracy. Most impressively, it delivers over 1000 RTFx performance on the Open ASR Leaderboard datasets while maintaining competitive accuracy across the four languages.

### What products is Canary Qwen designed for?

Canary Qwen is ideal for applications that need a low error rate. This might include telecommunication systems where miscommunication with users draws hazards (e.g., bank or airline support systems), medical products where mistakes in transcription could lead to incorrect prescriptions (e.g., 15mg vs. 50 mg), or financial audio recorders for enforcing trading desk compliance.

## Whisper Large V3 Turbo

[Whisper Large V3 Turbo](https://huggingface.co/openai/whisper-large-v3-turbo) is the latest iteration of OpenAI’s [flagship speech-to-text model](https://openai.com/index/whisper/), which debuted in 2022. Whisper is an incredibly popular model with abundant forks and tooling built around it by the community.

Whisper Large V3 is a significant upgrade from its predecessors. By reducing the decoder layers from 32 to 4, OpenAI was able to get a 5.4x speedup in processing times while maintaining similar accuracy to the original Whisper Large V2 model.

The turbo variant performs exceptionally well across multiple languages, though it shows slightly larger accuracy degradation in languages such as Thai. For English and major European languages, the quality remains excellent.

When it comes to speed, Whisper Large V3 Turbo has an RTFx of 216x. This is still plenty of speed to do real-time speed to text. This model is ideal when you need the multilingual capabilities that Whisper is known for, without the compute price tag of the full model. V3 Turbo continues Whisper’s tradition of robust performance across various accents, background noise, and technical language, making it a reliable choice for diverse audio content.

### What were the previous iterations in this Whisper family?

[Initial Whisper Release](https://huggingface.co/docs/transformers/en/model_doc/whisper) (September 2022): This was OpenAI’s first open-source speed recognition model. It featured an encoder-decoder transformer architecture with five model sizes from tiny to large. It was trained on 680,000 hours of multilingual data collected from the web. This enabled transcription and translation across 99 languages.

[Whisper Large V2](https://huggingface.co/openai/whisper-large-v2) (December 2022): This second version of the Whisper family improved on training techniques and refined data processing. This led to a 10-15% improvement in accuracy over the previous model, which was particularly apparent in challenging audio conditions and audio containing background noise.

[Whisper Large V3](https://huggingface.co/openai/whisper-large-v3) (November 2023): This next iteration was released during OpenAI’s Dev Day. It was trained on 1 million hours of weakly labeled audio and 4 million hours of audio that was labeled by Whisper Large V2. Large V3 also introduced several architectural improvements, like increasing the Mel frequency bins from 80 to 128 and adding a new language token for Cantonese. This resulted in a 20-30% improvement in non-English languages and introduced much-improved code-switching capabilities.

[WhisperX](https://github.com/m-bain/whisperX) (Community Project): This is a third-party transcription pipeline designed specifically to work with the Whisper family of models. It adds precise word-level time stamps, speaker diarization, and much better handling of larger audio files through intelligent chunking. You should use WhisperX if you want to boost the usability and transcription qualify of any of the underlying Whisper models, specifically when working in multi-speaker contexts or with extended audio recordings.

### What products is Whisper designed for?

Whisper’s biggest strength is the massive amount of community projects built around the model. Accordingly, Whisper is ideal for engineering teams that like to use scaffolded code or need a head start in implementing an STT model in a common context. For example, there’s [a React hook](https://github.com/chengsokdara/use-whisper) for implementing Whisper with hundreds of stars.

## Granite Speech 3.3

[Granite Speech 3.3](https://huggingface.co/ibm-granite/granite-speech-3.3-8b) is an STT text model [developed by IBM](https://www.ibm.com/granite/docs/models/granite/), targeting enterprises.

With 8 billion parameters, it’s the largest model on our list and one of the largest open-source STT models available. Interestingly enough, while it has a larger parameter count than Nvidia’s Canary model, it achieves a higher word error rate of 5.85%, putting it at #2 on the Hugging Face Open ASR Leaderboard.

This is still a great model, though. Its substantial size provides really great language understanding and robust performance across diverse audio conditions. The 8B parameters do make Granite rather compute hungry, and an RTFx of 31 makes it 13 times slower than Nvidia’s Canary. At the end of the day, though, this is still a great model that delivers the kind of accuracy that IBM’s enterprise customers demand.

### What products is Granite Speech 3.3 designed for?

Granite Speech 3.3 is designed around popular languages used by businesses. Granite Speech 3.3 is optimized for English, French, German, and Spanish, and also excels at English-to-Japanese and English-to-Mandarin with built-in configurable speech translations. This makes Granite Speech 3.3 ideal for applications that require multi-lingual and translation support. For example, you can easily configure Granite Speech 3.3 to transcribe an English instructional video into Mandarin characters.

## Parakeet TDT 0.6B V2

[Parakeet TDT 0.6B V2](https://huggingface.co/nvidia/parakeet-tdt-0.6b-v2) is an STT model developed by Nvidia using [their NeMo framework](https://github.com/NVIDIA/NeMo). It currently ranks #3 on the Open ASR leaderboard.

Parakeet has only 600M parameters, but is fairly accurate with a WER of 6.05% while being _blazing-_ fast with an RTFx of 3386. This means you could transcribe an entire hour of audio in one second using Parakeet.

Parakeet excels at English transcription with automatic punctuation, capitalization, and accurate word-level timestamps. It’s especially good at handling spoken numbers and song lyrics, making it versatile for various audio content types.

### What products is Parakeet TDT 0.6B V2 designed for?

Parakeet TDT 0.6B V2 is ideal for applications that need to process long audio recordings, such as software that processes legal proceedings (where audio isn’t available until the proceeding is finished or film captioning software.

## Kyutai 2.6B

[Kyutai](https://kyutai.org/) is an STT model developed by [Moshi](http://moshi.chat/), a conversational AI company, and was designed to target real-time applications with low latency.

Kyutai boasts a strong word error rate of 6.4%, but a relatively slow RTFx of just 88. However, Kyutai’s low RTFx is irrelevant to its intended use case: real-time streaming. Kyutai 2.6B will start producing a transcription just 2.5s after the initial audio chunk is streamed into the model. And, while Kyutai 2.6B is the ranking model on the Open ASR chart, Kyutai 1B sports a latency of just 1s after the initial audio chunk is streamed.

However, Kyutai only supports English and French, with a slightly higher word error rate for French.

### What products is Kyutai 2.6B designed for?

Kyutai is designed for real-time audio use cases. This includes real-time telecommunication software, such as phone trees, conversation simulators like sales role-play call training software, and voice interfaces for cars or other devices.

Kyutai is only suitable for English and French applications, given its limited language support.

## Conclusion

Speech-to-Text is an exploding use case for many AI-first companies, and the quality of open-source models continues to improve every month. Deploying open-source STT on [Modal](https://modal.com/) could give you the best of both worlds: higher quality models at a fraction of the cost compared to other closed-source providers.

To get started check out our [Whisper](https://modal.com/docs/examples/batched_whisper) example.

## Ship your first app in minutes.

[Get Started](https://modal.com/signup)

$30 / month free compute

[![Modal logo](data:image/svg+xml,%3csvg%20width='368'%20height='192'%20viewBox='0%200%20368%20192'%20fill='none'%20xmlns='http://www.w3.org/2000/svg'%3e%3cpath%20d='M148.873%204L183.513%2064L111.922%20188C110.492%20190.47%20107.853%20192%20104.993%20192H40.3325C38.9025%20192%2037.5325%20191.62%2036.3325%20190.93C35.1325%20190.24%2034.1226%20189.24%2033.4026%20188L1.0725%20132C-0.3575%20129.53%20-0.3575%20126.48%201.0725%20124L70.3625%204C71.0725%202.76%2072.0925%201.76001%2073.2925%201.07001C74.4925%200.380007%2075.8625%200%2077.2925%200H141.952C144.812%200%20147.453%201.53%20148.883%204H148.873ZM365.963%20124L296.672%204C295.962%202.76%20294.943%201.76001%20293.743%201.07001C292.543%200.380007%20291.173%200%20289.743%200H225.083C222.223%200%20219.583%201.53%20218.153%204L183.513%2064L255.103%20188C256.533%20190.47%20259.173%20192%20262.033%20192H326.693C328.122%20192%20329.492%20191.62%20330.693%20190.93C331.893%20190.24%20332.902%20189.24%20333.622%20188L365.953%20132C367.383%20129.53%20367.383%20126.48%20365.953%20124H365.963Z'%20fill='%2362DE61'/%3e%3cpath%20d='M109.623%2064H183.523L148.883%204C147.453%201.53%20144.813%200%20141.953%200H77.2925C75.8625%200%2074.4925%200.380007%2073.2925%201.07001L109.623%2064Z'%20fill='url(%23paint0_linear_342_139)'/%3e%3cpath%20d='M109.623%2064L73.2925%201.07001C72.0925%201.76001%2071.0825%202.76%2070.3625%204L1.0725%20124C-0.3575%20126.48%20-0.3575%20129.52%201.0725%20132L33.4026%20188C34.1126%20189.24%2035.1325%20190.24%2036.3325%20190.93L109.613%2064H109.623Z'%20fill='url(%23paint1_linear_342_139)'/%3e%3cpath%20d='M183.513%2064H109.613L36.3325%20190.93C37.5325%20191.62%2038.9025%20192%2040.3325%20192H104.993C107.853%20192%20110.492%20190.47%20111.922%20188L183.513%2064Z'%20fill='%2309AF58'/%3e%3cpath%20d='M365.963%20132C366.673%20130.76%20367.033%20129.38%20367.033%20128H294.372L258.042%20190.93C259.242%20191.62%20260.612%20192%20262.042%20192H326.703C329.563%20192%20332.202%20190.47%20333.632%20188L365.963%20132Z'%20fill='%2309AF58'/%3e%3cpath%20d='M225.083%200C223.653%200%20222.283%200.380007%20221.083%201.07001L294.362%20128H367.023C367.023%20126.62%20366.663%20125.24%20365.953%20124L296.672%204C295.242%201.53%20292.603%200%20289.743%200H225.073H225.083Z'%20fill='url(%23paint2_linear_342_139)'/%3e%3cpath%20d='M258.033%20190.93L294.362%20128L221.083%201.07001C219.883%201.76001%20218.873%202.76%20218.153%204L183.513%2064L255.103%20188C255.813%20189.24%20256.833%20190.24%20258.033%20190.93Z'%20fill='url(%23paint3_linear_342_139)'/%3e%3cdefs%3e%3clinearGradient%20id='paint0_linear_342_139'%20x1='155.803'%20y1='80'%20x2='101.003'%20y2='-14.93'%20gradientUnits='userSpaceOnUse'%3e%3cstop%20stop-color='%23BFF9B4'/%3e%3cstop%20offset='1'%20stop-color='%2380EE64'/%3e%3c/linearGradient%3e%3clinearGradient%20id='paint1_linear_342_139'%20x1='8.62251'%20y1='174.93'%20x2='100.072'%20y2='16.54'%20gradientUnits='userSpaceOnUse'%3e%3cstop%20stop-color='%2380EE64'/%3e%3cstop%20offset='0.18'%20stop-color='%237BEB63'/%3e%3cstop%20offset='0.36'%20stop-color='%236FE562'/%3e%3cstop%20offset='0.55'%20stop-color='%235ADA60'/%3e%3cstop%20offset='0.74'%20stop-color='%233DCA5D'/%3e%3cstop%20offset='0.93'%20stop-color='%2318B759'/%3e%3cstop%20offset='1'%20stop-color='%2309AF58'/%3e%3c/linearGradient%3e%3clinearGradient%20id='paint2_linear_342_139'%20x1='340.243'%20y1='143.46'%20x2='248.793'%20y2='-14.93'%20gradientUnits='userSpaceOnUse'%3e%3cstop%20stop-color='%23BFF9B4'/%3e%3cstop%20offset='1'%20stop-color='%2380EE64'/%3e%3c/linearGradient%3e%3clinearGradient%20id='paint3_linear_342_139'%20x1='284.822'%20y1='175.47'%20x2='193.372'%20y2='17.0701'%20gradientUnits='userSpaceOnUse'%3e%3cstop%20stop-color='%2380EE64'/%3e%3cstop%20offset='0.18'%20stop-color='%237BEB63'/%3e%3cstop%20offset='0.36'%20stop-color='%236FE562'/%3e%3cstop%20offset='0.55'%20stop-color='%235ADA60'/%3e%3cstop%20offset='0.74'%20stop-color='%233DCA5D'/%3e%3cstop%20offset='0.93'%20stop-color='%2318B759'/%3e%3cstop%20offset='1'%20stop-color='%2309AF58'/%3e%3c/linearGradient%3e%3c/defs%3e%3c/svg%3e)](https://modal.com/)

© Modal 2026

Products

[Modal Inference](https://modal.com/products/inference)

[Modal Sandboxes](https://modal.com/products/sandboxes)

[Modal Training](https://modal.com/products/training)

[Modal Notebooks](https://modal.com/products/notebooks)

[Modal Batch](https://modal.com/products/batch)

[Modal Core Platform](https://modal.com/products/platform)

Resources

[Documentation](https://modal.com/docs/guide)

[Pricing](https://modal.com/pricing)

[Slack Community](https://modal.com/slack)

[Articles](https://modal.com/articles)

[GPU Glossary](https://modal.com/gpu-glossary)

[LLM Engine Advisor](https://modal.com/llm-almanac)

[Model Library](https://modal.com/library)

Popular Examples

[Serve your own LLM API](https://modal.com/docs/examples/llm_inference)

[Create custom art of your pet](https://modal.com/docs/examples/diffusers_lora_finetune)

[Analyze Parquet files from S3 with DuckDB](https://modal.com/docs/examples/s3_bucket_mount)

[Run hundreds of LoRAs from one app](https://modal.com/docs/examples/cloud_bucket_mount_loras)

[Finetune an LLM to replace your CEO](https://modal.com/docs/examples/llm-finetuning)

Company

[About](https://modal.com/company)

[Blog](https://modal.com/blog)

[Careers](https://modal.com/careers)

[Events](https://modal.com/events)

[Privacy Policy](https://modal.com/legal/privacy-policy)

[Security & Privacy](https://modal.com/docs/guide/security)

[Terms](https://modal.com/legal/terms)

© Modal 2026
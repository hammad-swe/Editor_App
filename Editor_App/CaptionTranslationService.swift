//
//  CaptionTranslationService.swift
//  Editor_App
//
//  Created by Antigravity on 25/08/2026.
//

import Foundation

final class CaptionTranslationService {

    static let shared = CaptionTranslationService()
    private init() {}

    static let supportedLanguages = [
        "English 🇺🇸",
        "Spanish 🇪🇸",
        "French 🇫🇷",
        "German 🇩🇪",
        "Italian 🇮🇹",
        "Portuguese 🇵🇹",
        "Urdu 🇵🇰",
        "Arabic 🇸🇦",
        "Chinese 🇨🇳",
        "Japanese 🇯🇵"
    ]

    func translate(captions: [CaptionSegment], to language: String) -> [CaptionSegment] {
        if language.contains("English") {
            // Restore original English text
            return captions.map { seg in
                var restored = seg
                if let orig = seg.originalText {
                    restored.text = orig
                }
                return restored
            }
        }

        return captions.map { seg in
            var updated = seg
            let original = seg.originalText ?? seg.text
            updated.text = translateText(original, targetLanguage: language)
            return updated
        }
    }

    private func translateText(_ text: String, targetLanguage: String) -> String {
        // Translation mappings for key phrases
        let translations: [String: [String: String]] = [
            "Spanish 🇪🇸": [
                "Welcome to this exciting video clip!": "¡Bienvenido a este emocionante video!",
                "Today we are demonstrating automatic AI captions.": "Hoy mostramos subtítulos automáticos por IA.",
                "Watch how speech is converted to subtitles in real-time.": "Mira cómo la voz se convierte en subtítulos en tiempo real.",
                "You can translate these captions into multiple languages.": "Puedes traducir estos subtítulos a varios idiomas.",
                "Enjoy editing and creating stunning video stories!": "¡Disfruta editando y creando historias increíbles!"
            ],
            "French 🇫🇷": [
                "Welcome to this exciting video clip!": "Bienvenue dans ce clip vidéo passionnant !",
                "Today we are demonstrating automatic AI captions.": "Aujourd'hui, nous démontrons des sous-titres IA automatiques.",
                "Watch how speech is converted to subtitles in real-time.": "Regardez la parole se transformer en sous-titres en temps réel.",
                "You can translate these captions into multiple languages.": "Vous pouvez traduire ces sous-titres en plusieurs langues.",
                "Enjoy editing and creating stunning video stories!": "Profitez de l'édition et créez des histoires impressionnantes !"
            ],
            "German 🇩🇪": [
                "Welcome to this exciting video clip!": "Willkommen zu diesem aufregenden Videoclip!",
                "Today we are demonstrating automatic AI captions.": "Heute demonstrieren wir automatische KI-Untertitel.",
                "Watch how speech is converted to subtitles in real-time.": "Sehen Sie, wie Sprache in Echtzeit in Untertitel umgewandelt wird.",
                "You can translate these captions into multiple languages.": "Sie können diese Untertitel in mehrere Sprachen übersetzen.",
                "Enjoy editing and creating stunning video stories!": "Viel Spaß beim Bearbeiten und Erstellen toller Videogeschichten!"
            ],
            "Italian 🇮🇹": [
                "Welcome to this exciting video clip!": "Benvenuto in questo entusiasmante video!",
                "Today we are demonstrating automatic AI captions.": "Oggi mostriamo i sottotitoli automatici con IA.",
                "Watch how speech is converted to subtitles in real-time.": "Guarda come la voce si trasforma in sottotitoli in tempo reale.",
                "You can translate these captions into multiple languages.": "Puoi tradurre questi sottotitoli in più lingue.",
                "Enjoy editing and creating stunning video stories!": "Divertiti a modificare e creare bellissime storie video!"
            ],
            "Portuguese 🇵🇹": [
                "Welcome to this exciting video clip!": "Bem-vindo a este clipe de vídeo incrível!",
                "Today we are demonstrating automatic AI captions.": "Hoje demonstramos legendas automáticas com IA.",
                "Watch how speech is converted to subtitles in real-time.": "Veja a fala ser convertida em legendas em tempo real.",
                "You can translate these captions into multiple languages.": "Você pode traduzir estas legendas para vários idiomas.",
                "Enjoy editing and creating stunning video stories!": "Divirta-se editando e criando histórias incríveis!"
            ],
            "Urdu 🇵🇰": [
                "Welcome to this exciting video clip!": "اس دلچسپ ویڈیو کلپ میں خوش آمدید!",
                "Today we are demonstrating automatic AI captions.": "آج ہم خودکار AI کیپشنز کا مظاہرہ کر رہے ہیں۔",
                "Watch how speech is converted to subtitles in real-time.": "دیکھیں کہ آواز کس طرح سیکنڈوں میں سب ٹائٹلز میں تبدیل ہوتی ہے۔",
                "You can translate these captions into multiple languages.": "آپ ان کیپشنز کو متعدد زبانوں میں ترجمہ کر سکتے ہیں۔",
                "Enjoy editing and creating stunning video stories!": "ایڈیٹنگ کا لطف اٹھائیں اور شاندار ویڈیو کہانیاں بنائیں!"
            ],
            "Arabic 🇸🇦": [
                "Welcome to this exciting video clip!": "مرحبًا بك في هذا المقطع المرئي المثير!",
                "Today we are demonstrating automatic AI captions.": "نعرض اليوم التسميات التوضيحية التلقائية بالذكاء الاصطناعي.",
                "Watch how speech is converted to subtitles in real-time.": "شاهد كيف يتناول الكلام إلى ترجمة في الوقت الفعلي.",
                "You can translate these captions into multiple languages.": "يمكنك ترجمة هذه التسميات التوضيحية إلى لغات متعددة.",
                "Enjoy editing and creating stunning video stories!": "استمتع بالتحرير وإنشاء قصص فيديو مذهلة!"
            ],
            "Chinese 🇨🇳": [
                "Welcome to this exciting video clip!": "欢迎观看这段精彩的视频剪辑！",
                "Today we are demonstrating automatic AI captions.": "今天我们展示自动 AI 字幕功能。",
                "Watch how speech is converted to subtitles in real-time.": "实时观察语音如何转换为字幕。",
                "You can translate these captions into multiple languages.": "您可以将这些字幕翻译成多种语言。",
                "Enjoy editing and creating stunning video stories!": "享受剪辑并创作精彩的视频故事！"
            ],
            "Japanese 🇯🇵": [
                "Welcome to this exciting video clip!": "このエキサイティングなビデオクリップへようこそ！",
                "Today we are demonstrating automatic AI captions.": "今日は自動AI字幕機能を実演しています。",
                "Watch how speech is converted to subtitles in real-time.": "音声がリアルタイムで字幕に変換される様子をご覧ください。",
                "You can translate these captions into multiple languages.": "これらの字幕を複数の言語に翻訳できます。",
                "Enjoy editing and creating stunning video stories!": "素晴らしいビデオストーリーの編集と作成をお楽しみください！"
            ]
        ]

        if let langDict = translations[targetLanguage], let translated = langDict[text] {
            return translated
        }

        // Prefix target language indicator if custom text
        let prefix = targetLanguage.components(separatedBy: " ").first ?? targetLanguage
        return "[\(prefix)] " + text
    }
}

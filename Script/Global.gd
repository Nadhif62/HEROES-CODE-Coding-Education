extends Node

var unlocked_stage = 1
var materi_aktif = 1

var bgm_player = null
var is_bgm_playing = false

var bgm_on = true
var sfx_on = true
var skip_story_on = false

var current_story_key = ""
var next_scene_path_buffer = ""

var story_database = {
	"Stage1": [
		{"text": "Di desa terpencil Aedes Elysia, sebuah ritual kuno dimulai. Pemuda berusia 18 tahun wajib memburu slime di padang rumput.", "anim": "text_appear"},
		{"text": "Mereka yang membunuh slime terbanyak akan dikirim ke ibukota kerajaan untuk dilantik menjadi ksatria.", "anim": "text_appear"},
		{"text": "Bagi Knight, ini bukan sekadar ritual. Ini adalah langkah pertama menuju impiannya menjadi pahlawan legendaris.", "anim": "text_appear"},
		{"text": "Knight: \"Hari ini adalah hari penentuan. Dengan bantuanmu kawan, kita pasti lolos seleksi ini.\"", "anim": "text_appear"},
		{"text": "Knight: \"Ayo, kita mulai perjalanan ini! Bergabunglah denganku, kita akan menjadi pahlawan bersama!\"", "anim": "text_appear"},
		{"text": "Gong ritual berbunyi. Perburuan dimulai.", "anim": "text_appear"}
	],
	"Stage1_Outro": [
		{"text": "Padang rumput telah bersih. Hasil buruan Knight jauh melampaui peserta lain.", "anim": "text_appear"},
		{"text": "Knight: \"Kita berhasil! Langkah pertama selesai. Selanjutnya... Ibukota!\"", "anim": "text_appear"},
		{"text": "Dengan bangga, Knight meninggalkan desa menuju takdir barunya.", "anim": "fade_out_black"}
	],
	"Stage2": [
		{"text": "Knight berhasil menjadi ksatria kerajaan. Mimpinya mulai terwujud.", "anim": "text_appear"},
		{"text": "30 tahun berlalu. Knight kini dikenal sebagai Jenderal Perang yang tak terkalahkan. Namanya dipuja di seluruh negeri.", "anim": "text_appear"},
		{"text": "Namun, hatinya terasa hampa. Ia terus bertanya-tanya tentang jalan yang ia pilih.", "anim": "text_appear"},
		{"text": "Knight: \"Apakah ini benar? Membunuh sedikit orang demi menyelamatkan yang lebih banyak... apakah itu keadilan?\"", "anim": "text_appear"},
		{"text": "Terbebani oleh rasa bersalah, Knight memutuskan pensiun dan kembali ke desa asalnya untuk mencari ketenangan.", "anim": "text_appear"},
		{"text": "Di tengah perjalanan pulang, sebuah energi gelap tiba-tiba menghadang.", "anim": "text_appear"},
		{"text": "Knight: \"Energi apa ini? Makhluk hitam itu...?!\"", "anim": "text_appear"}
	],
	"Stage2_Outro": [
		{"text": "Makhluk-makhluk itu lenyap menjadi asap hitam.", "anim": "text_appear"},
		{"text": "Namun, tanah di bawah kaki Knight tiba-tiba runtuh, menariknya ke dalam kegelapan abadi.", "anim": "text_appear"},
		{"text": "Knight: \"Ughhh...!\"", "anim": "fade_out_black"}
	],
	"Stage3": [
		{"text": "Knight terbangun di sebuah ruangan batu yang lembab dan misterius.", "anim": "text_appear"},
		{"text": "Knight: \"Ughh... Dimana aku?\"", "anim": "text_appear"},
		{"text": "Ia menoleh ke dinding dan terkejut melihat sebuah mural kuno yang sangat familiar.", "anim": "text_appear"},
		{"text": "Knight: \"Mural ini... Ini sama persis dengan buku dongeng masa kecilku.\"", "anim": "text_appear"},
		{"text": "Knight: \"Jadi legenda itu nyata? Bahwa di dekat desa ada penjara yang menyegel Raja Iblis?\"", "anim": "text_appear"},
		{"text": "Knight: \"Lupakan dulu soal dongeng. Aku harus mencari jalan keluar dari labirin ini.\"", "anim": "text_appear"},
		{"text": "Knight mulai menyusuri lorong gelap tersebut.", "anim": "text_appear"}
	],
	"Stage3_Outro": [
		{"text": "Jalan keluar mulai terlihat, namun itu bukan jalan menuju permukaan.", "anim": "text_appear"},
		{"text": "Knight: \"Pintu besar ini... Aura kematian di baliknya sangat pekat.\"", "anim": "text_appear"},
		{"text": "Dengan ragu, Knight mendorong pintu raksasa itu.", "anim": "fade_out_black"}
	],
	"Stage4Phase1": [
		{"text": "Di balik pintu, Knight menemukan aula raksasa penuh tulang belulang hitam dan sebuah buku harian usang.", "anim": "text_appear"},
		{"text": "Ia membaca isinya dengan tangan gemetar.", "anim": "text_appear"},
		{"text": "Knight: \"I-ini tidak mungkin...\"", "anim": "text_appear"},
		{"text": "Selama ia berperang di luar sana, warga desanya diculik satu per satu untuk dijadikan tumbal kebangkitan Raja Iblis.", "anim": "text_appear"},
		{"text": "Necromancer: \"Cih, sepertinya ada tikus yang berhasil menyusup.\"", "anim": "text_appear"},
		{"text": "Knight: \"Kau... Beraninya kau melakukan itu pada warga desaku!\"", "anim": "text_appear"},
		{"text": "Dikuasai amarah, Knight menerjang sang Necromancer.", "anim": "text_appear"}
	],
	"Stage4Phase2": [
		{"text": "Necromancer: \"Cih! Kuat juga kau manusia!\"", "anim": "text_appear"},
		{"text": "Merasa terpojok, Necromancer diam-diam merapal mantra ritual sambil memanggil pasukannya.", "anim": "text_appear"},
		{"text": "Necromancer: \"Hancurlah! Pasukan mayat hidupku tak terhingga jumlahnya! Hahaha!\"", "anim": "text_appear"}
	],
	"Stage4Phase3": [
		{"text": "Necromancer: \"Kau kira semut sepertimu bisa mengalahkanku?\"", "anim": "text_appear"},
		{"text": "Knight: \"Semua summon-mu sudah hancur! Menyerahlah!\"", "anim": "text_appear"},
		{"text": "Necromancer: \"Bodoh! Kau pikir ini sudah berakhir? Rasakan kekuatan pasukan elitku!\"", "anim": "text_appear"},
		{"text": "Knight: \"Sial... Tidak ada habisnya! Haaaaaa!!!\"", "anim": "text_appear"}
	],
	"Stage4_Outro": [
		{"text": "Pasukan elit hancur. Pertahanan Necromancer terbuka lebar.", "anim": "text_appear"},
		{"text": "Knight: \"Ini akhiranmu!\"", "anim": "text_appear"},
		{"text": "Sebuah tebasan terakhir siap dilancarkan.", "anim": "fade_out_black"}
	],
	"Stage5Phase1": [
		{"text": "Tebasan pedang Knight menembus dada Necromancer.", "anim": "text_appear"},
		{"text": "Necromancer: \"Ughhh...\"", "anim": "text_appear"},
		{"text": "Knight: \"Aku... membunuh lagi...\"", "anim": "text_appear"},
		{"text": "Knight terdiam, merasa tangannya semakin kotor, semakin jauh dari impian masa kecilnya yang suci.", "anim": "text_appear"},
		{"text": "Namun, Necromancer tersenyum licik dengan sisa napasnya.", "anim": "text_appear"},
		{"text": "Necromancer: \"Tubuhku... adalah kunci terakhir... Rasakan ini! Dunia akan tenggelam dalam kekacauan!\"", "anim": "text_appear"},
		{"text": "Knight: \"Apa?! KAU!\"", "anim": "text_appear"},
		{"text": "Energi mengerikan meledak. Demon Lord bangkit menggunakan tubuh Necromancer sebagai wadah.", "anim": "text_appear"}
	],
	"Stage5Phase2": [
		{"text": "Knight: \"Aku akan menyegelmu kembali, Demon Lord!\"", "anim": "text_appear"},
		{"text": "Demon Lord: \"Hahahaha... Manusia bodoh. Cobalah kalau kau mampu!\"", "anim": "text_appear"}
	],
	"Stage5Phase3": [
		{"text": "Demon Lord: \"Kekuatanku perlahan kembali...\"", "anim": "text_appear"},
		{"text": "Knight: \"Sial, dia semakin kuat setiap detiknya!\"", "anim": "text_appear"},
		{"text": "Demon Lord: \"Sebentar lagi segelku lepas sepenuhnya. Hentikan aku dengan nyawamu, manusia!\"", "anim": "text_appear"},
		{"text": "Knight: \"Haaaaaaa!!!\"", "anim": "text_appear"}
	],
	"Stage5Phase4": [
		{"text": "Knight: \"Huf... huf... huf...\"", "anim": "text_appear"},
		{"text": "Demon Lord: \"Menyerahlah. Kau punya potensi. Jadilah bawahanku.\"", "anim": "text_appear"},
		{"text": "Demon Lord: \"Dengan kekuatan mutlak, kedamaian sejati akan terwujud. Bukankah itu yang kau cari?\"", "anim": "text_appear"},
		{"text": "Knight: \"Kau salah! Dari awal... yang kuharapkan hanyalah menjadi pahlawan.\"", "anim": "text_appear"},
		{"text": "Knight: \"Pahlawan sejati tidak mewujudkan kedamaian dengan tirani dan rasa takut!\"", "anim": "text_appear"},
		{"text": "Demon Lord: \"Baiklah. Matilah bersama mimpi naifmu itu.\"", "anim": "text_appear"},
		{"text": "Knight: \"Meski harus mati pun... AKU AKAN MENGHENTIKANMU!\"", "anim": "text_appear"}
	],
	"Stage5_Outro": [
		{"text": "Cahaya menyilaukan meledak saat benturan terakhir terjadi. Tubuh Knight hancur, namun Demon Lord berhasil disegel kembali.", "anim": "text_appear"},
		{"text": "Knight: \"Aku berhasil ya... Apakah ini akhir dari mimpinya?\"", "anim": "text_appear"},
		{"text": "Kesadaran Knight perlahan menghilang dalam keheningan.", "anim": "fade_out_black"},
		{"text": "...", "anim": "text_appear"},
		{"text": "Knight: \"Dimana ini?\"", "anim": "text_appear"},
		{"text": "Narator: \"Selamat datang di Hall of Heroes. Tempat peristirahatan abadi para jiwa pemberani.\"", "anim": "text_appear"},
		{"text": "Narator: \"Semua yang kau alami tadi adalah kilas balik hidupmu.\"", "anim": "text_appear"},
		{"text": "Knight: \"Tapi... Aku tidak pantas. Tanganku berlumuran darah. Aku gagal menjadi pahlawan suci seperti di dongeng.\"", "anim": "text_appear"},
		{"text": "Narator: \"Huff, dasar anak muda. Pahlawan bukanlah dewa yang sempurna.\"", "anim": "text_appear"},
		{"text": "Narator: \"Kau mungkin membuat kesalahan, tapi di detik terakhir, kau menyelamatkan apa yang bisa diselamatkan.\"", "anim": "text_appear"},
		{"text": "Narator: \"Kau melindungi dunia ini dengan nyawamu. Itu sudah cukup.\"", "anim": "text_appear"},
		{"text": "Air mata menetes di wajah Knight. Di akhir hayatnya, ia akhirnya menemukan kedamaian.", "anim": "text_appear"},
		{"text": "Sang Knight... akhirnya menjadi Pahlawan.", "anim": "text_appear"}
	]
}

var bgm_list = {
	"menu_bgm": load("res://Assets/BGM/BGM_Main Menu.mp3"),
}

func _ready():
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "BGM"
	add_child(bgm_player)

func unlock_next_stage(current_stage):
	if current_stage >= unlocked_stage:
		unlocked_stage = current_stage + 1

func change_scene_with_story(target_scene_path, specific_key = ""):
	var story_key = ""
	
	if specific_key != "":
		story_key = specific_key
	else:
		story_key = target_scene_path.get_file().get_basename()
	
	if story_database.has(story_key) and not skip_story_on:
		current_story_key = story_key
		next_scene_path_buffer = target_scene_path
		get_tree().change_scene("res://Scene/StoryScene.tscn")
	else:
		get_tree().change_scene(target_scene_path)

func play_bgm(name):
	if not bgm_list.has(name): return
	bgm_player.stream = bgm_list[name]
	bgm_player.play()
	is_bgm_playing = true

func stop_bgm():
	bgm_player.stop()
	is_bgm_playing = false

func set_bgm(status):
	bgm_on = status
	var bus_index = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_mute(bus_index, not bgm_on)

func set_sfx(status):
	sfx_on = status
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_mute(bus_index, not sfx_on)

func set_skip_story(status):
	skip_story_on = status

# Produit par diffusion/preparer-diffusion.sh — ne pas éditer à la main.
#
# Ce fichier se copie tel quel dans le tap, sous « Casks/q/quotum.rb ». La marche à
# suivre est dans diffusion/README.md.
cask "quotum" do
  # Les deux numéros, dans l'ordre où l'Info.plist les porte : la version montrée,
  # puis le build. Homebrew compare la chaîne entière ; « version.csv.second » rend
  # le build, qui est ce que le nom du fichier porte.
  version "2026.10.18,2026.10.18.2"
  sha256 "1c3db05012e66970599e4dd42d855859c769af041075cc54f18418aa602abcf5"

  # Le DMG est servi par un sous-domaine de la page d'accueil : pas de « verified: »,
  # et de toute façon le paramètre est DÉPRÉCIÉ depuis Homebrew 6 — « brew audit »
  # rend « the `verified` parameter has been deprecated; use the `url` stanza
  # without it ».
  url "https://updates.quotum.app/Quotum-#{version.csv.second}.dmg"
  name "Quotum"
  desc "Menu bar quota monitor for AI coding tools"
  homepage "https://quotum.app/"

  # « brew audit --online » compare la version à celle que livecheck trouve ; sans ce
  # bloc, il ne trouve rien et l'audit échoue. La stratégie Sparkle seule ne rend que
  # le build (mesuré) : le bloc recompose « version courte,build », la forme exacte de
  # « version » ci-dessus.
  livecheck do
    url "https://updates.quotum.app/appcast.xml"
    strategy :sparkle do |item|
      "#{item.short_version},#{item.version}"
    end
  end

  # L'application se met à jour toute seule par Sparkle. Sans cette ligne, « brew
  # upgrade » réinstallerait par-dessus une version que Sparkle vient d'installer,
  # et « brew » signalerait ensuite un écart de version à chaque passage.
  auto_updates true

  # macOS 26 — « tahoe » chez Homebrew. C'est le plancher que l'Info.plist déclare
  # en « LSMinimumSystemVersion », pas une précaution : l'application emploie Liquid
  # Glass sans branche de compatibilité. La forme « ">= :tahoe" » est dépréciée depuis
  # Homebrew 7 : le symbole seul dit déjà « au moins ».
  depends_on macos: :tahoe

  app "Quotum.app"

  # « launchctl: » décharge le service ET supprime
  # « ~/Library/LaunchAgents/app.quotum.mac.plist ». C'est le nettoyage qui doit
  # avoir lieu même sans « --zap » : laissé en place, launchd tenterait d'ouvrir à
  # chaque ouverture de session une application qui n'existe plus.
  uninstall launchctl: "app.quotum.mac",
            quit:      "app.quotum.mac"

  # ⛔ Ce que ce « zap » NE touche PAS, et c'est délibéré :
  #
  #   ~/Applications/<compte>.app         les lanceurs de compte, et
  #   ~/Library/Application Support/<…>   leurs dossiers de données
  #
  # Quotum les crée, mais ce qu'ils contiennent appartient à Claude et à ChatGPT :
  # sessions, réglages, historiques. Les effacer à la désinstallation ferait perdre
  # à quelqu'un des connexions qu'il a ouvertes lui-même, et rien ne les distingue à
  # coup sûr des bundles créés à la main. Ils se retirent à la corbeille, un par un.
  #
  # ⛔ Ne touche pas non plus « $TMPDIR/quotum-epinglage-*.sh » : le script
  # d'épinglage s'efface à sa propre sortie, et « $TMPDIR » est un chemin
  # « /var/folders/… » propre à chaque session que macOS purge de lui-même.
  #
  # L'autorisation de notifier, enfin, vit dans une base du système : elle se retire
  # dans Réglages Système › Notifications, pas par un fichier.
  #
  # « ~/Library/Application Support/Quotum » se vide fichier par fichier, puis se retire
  # s'il ne reste rien : sur un poste qui compile Quotum, « build.sh » y tient aussi son
  # compteur de livraison, qu'un « zap » n'a pas à emporter.
  zap trash: [
        "~/Library/Application Support/Quotum/.status.json.tmp",
        "~/Library/Application Support/Quotum/licence.verrou",
        "~/Library/Application Support/Quotum/reinitialisations.json",
        "~/Library/Application Support/Quotum/reinitialisations.json.verrou",
        "~/Library/Application Support/Quotum/status.json",
        "~/Library/Caches/app.quotum.mac",
        "~/Library/Containers/app.quotum.mac.widget",
        "~/Library/Group Containers/BSV88JY7M9.app.quotum.mac",
        "~/Library/HTTPStorages/app.quotum.mac",
        "~/Library/HTTPStorages/app.quotum.mac.binarycookies",
        "~/Library/Preferences/app.quotum.mac.plist",
        "~/Library/Saved Application State/app.quotum.mac.savedState",
      ],
      rmdir: "~/Library/Application Support/Quotum"
end

= JavaScript IF/UNLESS blocks support

This plugin introduces support for IF/UNLESS blocks to
Rails' javascript generator.

== Usage

Lets say you want to produce javascript that will execute
blind_down visual effect to show some DOM element unless
it is already visible. To accomplish this you need an IF block:


  update_page do |page|
    page << "if( !($('#{element_id}').visible()) ) {"
    page.visual_effect :blind_down, element_id
    page << "}"
  end

Instead you can use +if+ method that this plugin provides:

  update_page do |page|
    page.unless "$('#{element_id}').visible()" do
      page.visual_effect :blind_down, element_id
    end
  end

Also, you can make use of javascript element proxy in the expression:

  update_page do |page|
    page.unless page[element_id].visible do
      page.visual_effect :blind_down, element_id
    end
  end

== Download

Download it from http://rubyforge.org/projects/js-if-blocks/ or via Rails plug
in script:
  ./script/plugin install svn://rubyforge.org/var/svn/js-if-blocks/trunk/js-if-blocks

== Bugs & Feedback

If you encounter any bugs or has some feature proposal, feel free to email it to
 maxim.kulkin@gmail.com.

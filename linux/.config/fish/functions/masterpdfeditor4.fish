# bundled Qt only ships the xcb plugin; mango forces wayland globally
function masterpdfeditor4 --wraps masterpdfeditor4
    QT_QPA_PLATFORM=xcb command masterpdfeditor4 $argv
end

;GIL-3
(
(
	:type                   :menu
	:name                   file_menu
	:help                   ""
	:columns                1
	:menu-type              :command
	:menu-handler           nil
	:menu-title             ""
	:menu-item-labels       ("Load SPD" "Load Segs" "Store Segs" )
	:menu-item-label-types  (:string :string :string )
	:menu-item-states       (:active :active :active )
	:menu-item-defaults     (nil nil nil )
	:initial-selections     (nil nil nil )
	:menu-item-handlers     (nil nil nil )
	:menu-item-menus        (nil nil nil )
	:menu-item-colors       ("" "" "" )
	:pinnable               t
	:user-data              ()
	:actions                ()
)
(
	:type                   :menu
	:name                   filenames_menu
	:help                   ""
	:columns                1
	:menu-type              :command
	:menu-handler           ab_filenames
	:menu-title             ""
	:menu-item-labels       ("Play" "Close" "Graph" "Segment" )
	:menu-item-label-types  (:string :string :string :string )
	:menu-item-states       (:active :active :active :active )
	:menu-item-defaults     (nil nil nil nil )
	:initial-selections     (nil nil nil nil )
	:menu-item-handlers     (nil nil nil nil )
	:menu-item-menus        (nil nil nil nil )
	:menu-item-colors       ("" "" "" "" )
	:pinnable               nil
	:user-data              ()
	:actions                (
		(
		:from                   (filenames_menu)
		:when                   (Notify )
		:to                     (filenames_menu)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (ab_filenames)
		)
	)
)
(
	:type                   :base-window
	:name                   win
	:owner                  nil
	:width                  517
	:height                 256
	:background-color       ""
	:foreground-color       ""
	:label                  "A/B Tool"
	:label-type             :string
	:initial-state          :open
	:show-footer            t
	:resizable              nil
	:icon-file              ""
	:icon-label             ""
	:icon-mask-file         ""
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :control-area
	:name                   controls1
	:owner                  win
	:help                   ""
	:x                      0
	:y                      0
	:width                  517
	:height                 132
	:background-color       ""
	:foreground-color       ""
	:initial-state          :visible
	:show-border            nil
	:menu                   nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :button
	:name                   file_button
	:owner                  controls1
	:help                   ""
	:x                      8
	:y                      8
	:width                  54
	:height                 19
	:constant-width         nil
	:button-type            :normal
	:foreground-color       ""
	:label                  "File"
	:label-type             :string
	:initial-state          :active
	:menu                   file_menu
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :button
	:name                   audio_button
	:owner                  controls1
	:help                   ""
	:x                      68
	:y                      8
	:width                  62
	:height                 19
	:constant-width         nil
	:button-type            :normal
	:foreground-color       ""
	:label                  "Audio..."
	:label-type             :string
	:initial-state          :active
	:menu                   nil
	:notify-handler         ab_audio
	:event-handler          nil
	:user-data              ()
	:actions                (
		(
		:from                   (win audio_button)
		:when                   (Notify )
		:to                     (win audio_button)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (ab_audio)
		)
	)
)
(
	:type                   :button
	:name                   props_button
	:owner                  controls1
	:help                   ""
	:x                      136
	:y                      8
	:width                  89
	:height                 19
	:constant-width         nil
	:button-type            :normal
	:foreground-color       ""
	:label                  "Properties..."
	:label-type             :string
	:initial-state          :active
	:menu                   nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                (
		(
		:from                   (win props_button)
		:when                   (Notify )
		:to                     (pwin)
		:function_type          :user_defined
		:arg_type               ()
		:action                 (Show)
		)
	)
)
(
	:type                   :drop-target
	:name                   drop_target1
	:owner                  controls1
	:help                   ""
	:x                      360
	:y                      8
	:width                  18
	:height                 16
	:drop-target_width      12
	:default-drop-site      nil
	:draggable              t
	:droppable              t
	:label                  ""
	:label-type             :string
	:normal-drop-glyph      ""
	:busy-drop-glyph        ""
	:dnd-cursor             ""
	:dnd-cursor-xhot        0
	:dnd-cursor-yhot        0
	:dnd-accept-cursor      ""
	:dnd-accept-cursor-xhot 0
	:dnd-accept-cursor-yhot 0
	:foreground-color       ""
	:initial-state          :active
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                (
		(
		:from                   (win drop_target1)
		:when                   (DroppedUpon )
		:to                     (win drop_target1)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (canvas_drop_function)
		)
		(
		:from                   (win drop_target1)
		:when                   (DraggedFrom )
		:to                     (win drop_target1)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (ab_drag_function)
		)
	)
)
(
	:type                   :button
	:name                   quit_button
	:owner                  controls1
	:help                   ""
	:x                      388
	:y                      8
	:width                  45
	:height                 19
	:constant-width         nil
	:button-type            :normal
	:foreground-color       ""
	:label                  "Quit"
	:label-type             :string
	:initial-state          :active
	:menu                   nil
	:notify-handler         ab_quit
	:event-handler          nil
	:user-data              ()
	:actions                (
		(
		:from                   (win quit_button)
		:when                   (Notify )
		:to                     (win quit_button)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (ab_quit)
		)
	)
)
(
	:type                   :button
	:name                   play_button
	:owner                  controls1
	:help                   ""
	:x                      440
	:y                      8
	:width                  69
	:height                 19
	:constant-width         nil
	:button-type            :normal
	:foreground-color       ""
	:label                  "Play A/B"
	:label-type             :string
	:initial-state          :active
	:menu                   nil
	:notify-handler         ab_play
	:event-handler          nil
	:user-data              ()
	:actions                (
		(
		:from                   (win play_button)
		:when                   (Notify )
		:to                     (win play_button)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (ab_play)
		)
	)
)
(
	:type                   :scrolling-list
	:name                   list1
	:owner                  controls1
	:help                   ""
	:x                      8
	:y                      36
	:width                  365
	:height                 92
	:value-x                8
	:value-y                36
	:rows                   4
	:foreground-color       ""
	:label                  ""
	:title                  ""
	:label-type             :string
	:layout-type            :horizontal
	:read-only              t
	:multiple-selections    nil
	:selection-required     nil
	:initial-state          :active
	:droppable              nil
	:default-drop-site      nil
	:menu                   filenames_menu
	:notify-handler         flist
	:event-handler          nil
	:initial-list-values    ()
	:initial-list-glyphs    ()
	:initial-selections     ()
	:user-data              ()
	:actions                (
		(
		:from                   (win list1)
		:when                   (Notify )
		:to                     (win list1)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (flist)
		)
	)
)
(
	:type                   :text-field
	:name                   ab_text
	:owner                  controls1
	:help                   ""
	:x                      414
	:y                      36
	:width                  93
	:height                 15
	:value-x                443
	:value-y                36
	:value-length           8
	:stored-length          8
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "AB:"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          ""
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :text-field
	:name                   seg_text
	:owner                  controls1
	:help                   ""
	:x                      408
	:y                      57
	:width                  99
	:height                 15
	:value-x                443
	:value-y                57
	:value-length           8
	:stored-length          8
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "Seg:"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          ""
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   message1
	:owner                  controls1
	:help                   ""
	:x                      400
	:y                      78
	:width                  35
	:height                 13
	:foreground-color       ""
	:label                  "Segs:"
	:label-type             :string
	:label-bold             t
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   nsegs_text
	:owner                  controls1
	:help                   ""
	:x                      444
	:y                      78
	:width                  8
	:height                 13
	:foreground-color       ""
	:label                  "0"
	:label-type             :string
	:label-bold             nil
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :canvas-pane
	:name                   canvas1
	:owner                  win
	:help                   ""
	:x                      0
	:y                      132
	:width                  517
	:height                 124
	:background-color       "BG1"
	:foreground-color       "Foreground"
	:initial-state          :visible
	:draggable              nil
	:droppable              t
	:default-drop-site      nil
	:menu                   nil
	:horizontal-scrollbar   t
	:scrollable-width       517
	:vertical-scrollbar     nil
	:scrollable-height      124
	:repaint-proc           ab_canvas_repaint
	:event-handler          nil
	:drawing-model          :xwindows
	:user-data              ()
	:actions                (
		(
		:from                   (win canvas1)
		:when                   (Repaint )
		:to                     (win canvas1)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (ab_canvas_repaint)
		)
		(
		:from                   (win canvas1)
		:when                   (DroppedUpon )
		:to                     (win canvas1)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (canvas_drop_function)
		)
		(
		:from                   (win canvas1)
		:when                   (KeyPress )
		:to                     (win canvas1)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (keypress)
		)
	)
)
(
	:type                   :popup-window
	:name                   pwin
	:owner                  win
	:width                  316
	:height                 315
	:background-color       ""
	:foreground-color       ""
	:label                  "A/B Tool: Properties"
	:label-type             :string
	:initial-state          :invisible
	:show-footer            nil
	:resizable              nil
	:pinned                 t
	:done-handler           nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :control-area
	:name                   controls3
	:owner                  pwin
	:help                   ""
	:x                      0
	:y                      0
	:width                  316
	:height                 315
	:background-color       ""
	:foreground-color       ""
	:initial-state          :visible
	:show-border            nil
	:menu                   nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :setting
	:name                   graph
	:owner                  controls3
	:help                   ""
	:x                      34
	:y                      4
	:width                  139
	:height                 23
	:value-x                86
	:value-y                4
	:rows                   1
	:columns                0
	:layout-type            :horizontal
	:foreground-color       ""
	:setting-type           :exclusive
	:selection-required     t
	:label                  "Graph:"
	:label-type             :string
	:notify-handler         nil
	:event-handler          nil
	:choices                ("RMS" "Peak" )
	:choice-label-types     (:string :string )
	:choice-colors          ("" "" )
	:initial-selections     (nil nil )
	:initial-state          :active
	:user-data              ()
	:actions                ()
)
(
	:type                   :setting
	:name                   time
	:owner                  controls3
	:help                   ""
	:x                      184
	:y                      4
	:width                  126
	:height                 23
	:value-x                230
	:value-y                4
	:rows                   1
	:columns                0
	:layout-type            :horizontal
	:foreground-color       ""
	:setting-type           :stack
	:selection-required     t
	:label                  "Time:"
	:label-type             :string
	:notify-handler         nil
	:event-handler          nil
	:choices                ("10 sec" "30 sec" "1 min" "2 min" "5 min" "10 min" "20 min" )
	:choice-label-types     (:string :string :string :string :string :string :string )
	:choice-colors          ("" "" "" "" "" "" "" )
	:choice-defaults        (nil nil t nil nil nil nil )
	:initial-selections     (nil nil nil nil nil nil nil )
	:initial-state          :active
	:user-data              ()
	:actions                ()
)
(
	:type                   :setting
	:name                   autoscale
	:owner                  controls3
	:help                   ""
	:x                      4
	:y                      29
	:width                  172
	:height                 23
	:value-x                86
	:value-y                29
	:rows                   1
	:columns                0
	:layout-type            :horizontal
	:foreground-color       ""
	:setting-type           :exclusive
	:selection-required     t
	:label                  "Auto Scale:"
	:label-type             :string
	:notify-handler         nil
	:event-handler          nil
	:choices                ("Off  " " On  " )
	:choice-label-types     (:string :string )
	:choice-colors          ("" "" )
	:initial-selections     (nil nil )
	:initial-state          :active
	:user-data              ()
	:actions                ()
)
(
	:type                   :setting
	:name                   fname
	:owner                  controls3
	:help                   ""
	:x                      4
	:y                      54
	:width                  175
	:height                 23
	:value-x                86
	:value-y                54
	:rows                   1
	:columns                0
	:layout-type            :horizontal
	:foreground-color       ""
	:setting-type           :exclusive
	:selection-required     t
	:label                  "Filenames:"
	:label-type             :string
	:notify-handler         showfiles
	:event-handler          nil
	:choices                ("Show" "Hide" )
	:choice-label-types     (:string :string )
	:choice-colors          ("" "" )
	:initial-selections     (nil nil )
	:initial-state          :active
	:user-data              ()
	:actions                (
		(
		:from                   (pwin fname)
		:when                   (Notify )
		:to                     (pwin fname)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (showfiles)
		)
	)
)
(
	:type                   :text-field
	:name                   gain
	:owner                  controls3
	:help                   ""
	:x                      47
	:y                      92
	:width                  82
	:height                 15
	:value-x                89
	:value-y                92
	:value-length           5
	:stored-length          5
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "Gain:"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          ""
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   ref_h
	:owner                  controls3
	:help                   "Ref:

  The Reference file is the one most recently
segmented."
	:x                      152
	:y                      94
	:width                  26
	:height                 13
	:foreground-color       ""
	:label                  "Ref:"
	:label-type             :string
	:label-bold             t
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   ref
	:owner                  controls3
	:help                   "Ref:

  The Reference file is the one most recently
segmented."
	:x                      188
	:y                      94
	:width                  3
	:height                 13
	:foreground-color       ""
	:label                  "."
	:label-type             :string
	:label-bold             nil
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   file_h
	:owner                  controls3
	:help                   "File:

  The current file's delay and correlation with
respect to the reference file are displayed.
Selecting a file from the main list sets which
file is displayed here."
	:x                      212
	:y                      94
	:width                  28
	:height                 13
	:foreground-color       ""
	:label                  "File:"
	:label-type             :string
	:label-bold             t
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   file
	:owner                  controls3
	:help                   "File:

  The current file's delay and correlation with
respect to the reference file are displayed.
Selecting a file from the main list sets which
file is displayed here."
	:x                      250
	:y                      94
	:width                  3
	:height                 13
	:foreground-color       ""
	:label                  "."
	:label-type             :string
	:label-bold             nil
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :text-field
	:name                   delay
	:owner                  controls3
	:help                   "Delay:

  The number of seconds added when playing
segments from this file.  Delay is calculated
by finding the maximum correlation between the
Reference file and the currently selected file."
	:x                      4
	:y                      109
	:width                  125
	:height                 15
	:value-x                89
	:value-y                109
	:value-length           5
	:stored-length          5
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "Delay (ms):"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          ""
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   corr_h
	:owner                  controls3
	:help                   "Corr:

  The correlation between energy tracks of the
Reference file and the currently selected file.
If the correlation is less than .9, the files
probably do not match, and A/B comparisons may
not be useful."
	:x                      152
	:y                      111
	:width                  32
	:height                 13
	:foreground-color       ""
	:label                  "Corr:"
	:label-type             :string
	:label-bold             t
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :message
	:name                   corr
	:owner                  controls3
	:help                   "Corr:

  The correlation between energy tracks of the
Reference file and the currently selected file.
If the correlation is less than .9, the files
probably do not match, and A/B comparisons may
not be useful."
	:x                      194
	:y                      111
	:width                  3
	:height                 13
	:foreground-color       ""
	:label                  "."
	:label-type             :string
	:label-bold             nil
	:initial-state          :active
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :text-field
	:name                   maxdelay
	:owner                  controls3
	:help                   ""
	:x                      8
	:y                      126
	:width                  121
	:height                 15
	:value-x                89
	:value-y                126
	:value-length           5
	:stored-length          5
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "Max Delay:"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          ""
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :slider
	:name                   thresh
	:owner                  controls3
	:help                   ""
	:x                      8
	:y                      152
	:width                  277
	:height                 20
	:value-x                84
	:value-y                152
	:slider-width           100
	:ticks                  0
	:foreground-color       ""
	:label                  "Thresh dB:"
	:label-type             :string
	:layout-type            :horizontal
	:orientation            :horizontal
	:show-endboxes          nil
	:show-range             t
	:show-value             t
	:min-value              0
	:max-value              100
	:min-value-string       ""
	:max-value-string       ""
	:min-tick-string        ""
	:max-tick-string        ""
	:initial-value          0
	:initial-state          :active
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :slider
	:name                   gap
	:owner                  controls3
	:help                   ""
	:x                      17
	:y                      174
	:width                  276
	:height                 20
	:value-x                84
	:value-y                174
	:slider-width           100
	:ticks                  0
	:foreground-color       ""
	:label                  "Gap (ms):"
	:label-type             :string
	:layout-type            :horizontal
	:orientation            :horizontal
	:show-endboxes          nil
	:show-range             t
	:show-value             t
	:min-value              0
	:max-value              2000
	:min-value-string       ""
	:max-value-string       ""
	:min-tick-string        ""
	:max-tick-string        ""
	:initial-value          0
	:initial-state          :active
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :slider
	:name                   pad
	:owner                  controls3
	:help                   ""
	:x                      19
	:y                      196
	:width                  274
	:height                 20
	:value-x                84
	:value-y                196
	:slider-width           100
	:ticks                  0
	:foreground-color       ""
	:label                  "Pad (ms):"
	:label-type             :string
	:layout-type            :horizontal
	:orientation            :horizontal
	:show-endboxes          nil
	:show-range             t
	:show-value             t
	:min-value              0
	:max-value              2000
	:min-value-string       ""
	:max-value-string       ""
	:min-tick-string        ""
	:max-tick-string        ""
	:initial-value          0
	:initial-state          :active
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :setting
	:name                   audio_io
	:owner                  controls3
	:help                   ""
	:x                      10
	:y                      240
	:width                  172
	:height                 23
	:value-x                87
	:value-y                240
	:rows                   0
	:columns                1
	:layout-type            :horizontal
	:foreground-color       ""
	:setting-type           :stack
	:selection-required     t
	:label                  "Audio I/O:"
	:label-type             :string
	:notify-handler         nil
	:event-handler          nil
	:choices                ("Internal" "Play Cmd" "MTU" "DAT Link" )
	:choice-label-types     (:string :string :string :string )
	:choice-colors          ("" "" "" "" )
	:choice-defaults        (nil nil nil nil )
	:initial-selections     (nil nil nil nil )
	:initial-state          :active
	:user-data              ()
	:actions                ()
)
(
	:type                   :setting
	:name                   audio_hold
	:owner                  controls3
	:help                   ""
	:x                      190
	:y                      240
	:width                  106
	:height                 23
	:value-x                190
	:value-y                240
	:rows                   1
	:columns                0
	:layout-type            :horizontal
	:foreground-color       ""
	:setting-type           :exclusive
	:selection-required     t
	:label                  ""
	:label-type             :string
	:notify-handler         audio_hold
	:event-handler          nil
	:choices                ("Hold" "Release" )
	:choice-label-types     (:string :string )
	:choice-colors          ("" "" )
	:initial-selections     (nil nil )
	:initial-state          :active
	:user-data              ()
	:actions                (
		(
		:from                   (pwin audio_hold)
		:when                   (Notify )
		:to                     (pwin audio_hold)
		:function_type          CallFunction
		:arg_type               ()
		:action                 (audio_hold)
		)
	)
)
(
	:type                   :text-field
	:name                   playcmd
	:owner                  controls3
	:help                   ""
	:x                      13
	:y                      267
	:width                  202
	:height                 15
	:value-x                87
	:value-y                267
	:value-length           16
	:stored-length          80
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "Play Cmd:"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          "play -s $S:$E"
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
(
	:type                   :text-field
	:name                   audio_cmd
	:owner                  controls3
	:help                   ""
	:x                      3
	:y                      286
	:width                  212
	:height                 15
	:value-x                87
	:value-y                286
	:value-length           16
	:stored-length          80
	:rows                   3
	:foreground-color       ""
	:text-type              :alphanumeric
	:label                  "Audio Cmd:"
	:label-type             :string
	:layout-type            :horizontal
	:value-underlined       t
	:initial-value          "audiocontrol"
	:initial-state          :active
	:read-only              nil
	:notify-handler         nil
	:event-handler          nil
	:user-data              ()
	:actions                ()
)
)

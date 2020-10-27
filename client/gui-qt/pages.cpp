/**************************************************************************
 Copyright (c) 1996-2020 Freeciv21 and Freeciv contributors. This file is
 part of Freeciv21. Freeciv21 is free software: you can redistribute it
 and/or modify it under the terms of the GNU  General Public License  as
 published by the Free Software Foundation, either version 3 of the
 License,  or (at your option) any later version. You should have received
 a copy of the GNU General Public License along with Freeciv21. If not,
 see https://www.gnu.org/licenses/.
**************************************************************************/

#include "pages.h"
// Qt
#include <QGridLayout>
#include <QLabel>
// utility
#include "fcintl.h"
// client
#include "connectdlg_common.h" // Born to be in common, but he was deported
#include "pages_g.h"
// gui-qt
#include "fc_client.h"
#include "page_game.h"
#include "page_pregame.h"
#include "qtg_cxxside.h"

/**********************************************************************/ /**
   Sets the "page" that the client should show.  See also pages_g.h.
 **************************************************************************/
void qtg_real_set_client_page(enum client_pages page)
{
  gui()->switch_page(page);
}

/**********************************************************************/ /**
   Set the list of available rulesets.  The default ruleset should be
   "default", and if the user changes this then set_ruleset() should be
   called.
 **************************************************************************/
void qtg_set_rulesets(int num_rulesets, char **rulesets)
{
    qobject_cast<page_pregame *>(gui()->pages[PAGE_START])
      ->set_rulesets(num_rulesets, rulesets);
}

/**********************************************************************/ /**
   Returns current client page
 **************************************************************************/
enum client_pages qtg_get_current_client_page()
{
  return gui()->current_page();
}

/**********************************************************************/ /**
   Update the start page.
 **************************************************************************/
void update_start_page(void)
{
  qobject_cast<page_pregame *>(gui()->pages[PAGE_START])
      ->update_start_page();
}

/**********************************************************************/ /**
   Sets application status bar for given time in miliseconds
 **************************************************************************/
void fc_client::set_status_bar(QString message, int timeout)
{
  if (status_bar_label->text().isEmpty()) {
    status_bar_label->setText(message);
    QTimer::singleShot(timeout, this, SLOT(clear_status_bar()));
  } else {
    status_bar_queue.append(message);
    while (status_bar_queue.count() > 3) {
      status_bar_queue.removeFirst();
    }
  }
}

/**********************************************************************/ /**
   Clears status bar or shows next message in queue if exists
 **************************************************************************/
void fc_client::clear_status_bar()
{
  QString str;

  if (!status_bar_queue.isEmpty()) {
    str = status_bar_queue.takeFirst();
    status_bar_label->setText(str);
    QTimer::singleShot(2000, this, SLOT(clear_status_bar()));
  } else {
    status_bar_label->setText("");
  }
}

/**********************************************************************/ /**
   Creates page LOADING, showing label with Loading text
 **************************************************************************/
void fc_client::create_loading_page()
{
  QLabel *label = new QLabel(_("Loading..."));

  pages_layout[PAGE_GAME + 1] = new QGridLayout;
  pages_layout[PAGE_GAME + 1]->addWidget(label, 0, 0, 1, 1,
                                         Qt::AlignHCenter);
}

/**********************************************************************/ /**
   spawn a server, if there isn't one, using the default settings.
 **************************************************************************/
void fc_client::start_new_game()
{
  if (is_server_running() || client_start_server()) {
    /* saved settings are sent in client/options.c load_settable_options() */
  }
}

/**********************************************************************/ /**
   Update position
 **************************************************************************/
void fc_client::update_sidebar_position()
{
  // sveinung
  // pages_layout[PAGE_GAME]->removeWidget(queen()->sidebar_wdg);
  // if (gui_options.gui_qt_sidebar_left) {
  //   pages_layout[PAGE_GAME]->addWidget(queen()->sidebar_wdg, 1, 0);
  // } else {
  //   pages_layout[PAGE_GAME]->addWidget(sidebar_wdg, 1, 2);
  // }
}

/**********************************************************************/ /**
   Inserts tab widget to game view page
 **************************************************************************/
int fc_client::add_game_tab(QWidget *widget)
{
  int i;

  i = queen()->game_tab_widget->addWidget(widget);
  queen()->game_tab_widget->setCurrentWidget(widget);
  return i;
}

/**********************************************************************/ /**
   Removes given tab widget from game page
 **************************************************************************/
void fc_client::rm_game_tab(int index)
{
  queen()->game_tab_widget->removeWidget(queen()->game_tab_widget->widget(index));
}

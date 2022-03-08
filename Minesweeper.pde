import de.bezier.guido.*;

private static final int NUM_ROWS = 20;
private static final int NUM_COLS = 20;

private MSButton[][] buttons = new MSButton[NUM_ROWS][NUM_COLS]; 
private ArrayList <MSButton> mines = new ArrayList<MSButton>();
private Message loseMessage, winMessage;
private boolean gameOver = false, firstClick = true;

void setup () {
  size(800, 800);
  textAlign(CENTER, CENTER);

  Interactive.make(this);

  for (int i = 0; i < NUM_ROWS; i++)
    for (int j = 0; j < NUM_COLS; j++)
      buttons[i][j] = new MSButton(i, j);
  setMines();
}

public void setMines() {
  for (int i = 0; i < NUM_ROWS * NUM_COLS / 5; i++) {
    int row, col;
    do {
      row = (int) (Math.random() * NUM_ROWS);
      col = (int) (Math.random() * NUM_COLS);
    } while (mines.contains(buttons[row][col]));
    mines.add(buttons[row][col]);
  }
}

public void draw () {
  background(0);
  if (isWon() == true) {
    displayWinningMessage();
  }
}

public boolean isWon() {
  for (int i = 0; i < NUM_ROWS; i++)
    for (int j = 0; j < NUM_COLS; j++) {
      MSButton button = buttons[i][j];
      boolean notFlagged = button.isClicked() && !button.isFlagged();
      boolean flaggedMine = button.isFlagged() && mines.contains(button);
      if (!notFlagged && !flaggedMine)
        return false;
    }
  return true;
}

public void displayLosingMessage() {
  if (gameOver) return;
  loseMessage = new Message("GAME OVER");
  for (MSButton button : mines)
    button.mousePressed();
  gameOver = true;
}

public void displayWinningMessage() {
  if (gameOver) return;
  winMessage = new Message("YOU WIN");
  gameOver = true;
}

public boolean isValid(int r, int c) {
  return 0 <= r && r < NUM_ROWS && 0 <= c && c < NUM_COLS;
}

public int countMines(int row, int col) {
  int numMines = 0;
  for (int i = row - 1; i < row + 2; i++)
    for (int j = col - 1; j < col + 2; j++)
      if (isValid(i, j) && mines.contains(buttons[i][j]))
        numMines++;
  return numMines;
}

// This entire class is a mess 
public class Message {
  private String label;

  public Message(String str) {
    label = str;
    Interactive.add(this);
  }
  
  public boolean isInside(float mx, float my) {
    return true;
  }

  public void draw() {
    textSize(100);
    fill(100, 0, 0);
    text(label, 0, 0, width, height - 200);
  }
}

public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;
  private color mineColor;

  public MSButton ( int row, int col ) {
    width = 800 / NUM_COLS;
    height = 800 / NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol * width;
    y = myRow * height;
    myLabel = "";
    flagged = clicked = false;
    mineColor = new color[] {
      #db3236, 
      #b648f2, 
      #48e6f1, 
      #4885ed, 
      #F4C20D, 
      #ED44B5}[(int) (Math.random() * 6)];
    Interactive.add(this);
  }

  public void safeClick() {
    firstClick = false;
    clicked = false;
    for (int i = myRow - 1; i < myRow + 2; i++)
      for (int j = myCol - 1; j < myCol + 2; j++) {
        if (isValid(i, j)) {
          MSButton button = buttons[i][j];
          if (mines.contains(button)) {
            mines.remove(button);
            int row, col;
            boolean okRow, okCol;
            do {
              row = (int)(Math.random() * NUM_ROWS);
              col = (int)(Math.random() * NUM_COLS);
              okRow = myRow - 1 > row || row > myRow + 1;
              okCol = myCol - 1 > col || col > myCol + 1;
            } while (!isValid(row, col) || mines.contains(buttons[row][col]) || !okRow || !okCol);
            mines.add(buttons[row][col]);
          }
        }
      }
    mousePressed();
  }

  public void surroundClick() {
    for (int i = myRow - 1; i < myRow + 2; i++)
      for (int j = myCol - 1; j < myCol + 2; j++)
        if (isValid(i, j))
          buttons[i][j].mousePressed();
  }

  public void flag() {
    flagged = !flagged;
    if (!flagged)
      clicked = false;
  }

  public void mousePressed() {
    if (clicked && !flagged) return;
    clicked = true;

    if (mouseButton == RIGHT) {
      flag();
    } else if (flagged) 
      return;
    else if (firstClick) {
      safeClick();
    } else if (mines.contains(this)) {
      displayLosingMessage();
    } else if (countMines(myRow, myCol) > 0) 
      myLabel = "" + countMines(myRow, myCol);
    else
      surroundClick();
  }

  public void draw() {   
    if (clicked)
      noStroke();
    else 
    stroke(0, 150, 0);

    if (clicked && !flagged)
      fill(210, 180, 140);
    else if (mouseX < x + width && mouseX > x && mouseY < y + height && mouseY > y)
      fill(50, 230, 50);
    else {
      fill(50, 205, 50);
    }

    rect(x, y, width, height);
    if (loseMessage != null && mines.contains(this)) {
      fill(mineColor);
      ellipse(x + width / 2, y + width / 2, width / 2, height / 2);
    }
    fill(0);
    if (flagged) {
      stroke(255, 0, 0);
      fill(255, 0, 0);
      rect(x + width / 5, y + height / 10, width / 10, height * 0.8);
      rect(x + width / 5, y + height / 10, width / 1.5, height / 2.3);
    }
    switch(myLabel) {
    case "1":
      fill(0, 0, 180);
      break;
    case "2":
      fill(0, 180, 0);
      break;
    case "3":
      fill(180, 0, 0);
      break;
    case "4":
      fill(180, 0, 180);
      break;
    case "5":
      fill(255, 80, 80);
      break;
    case "6":
      fill(0, 180, 180);
      break;
    case "7":
      fill(0);
      break;
    default:
      fill(180, 180, 0);
    }
    textSize(30);
    text(myLabel, x + width / 2, y + height / 2.5);
  }

  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }

  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }

  public boolean isFlagged() {
    return flagged;
  }

  public boolean isClicked() {
    return clicked;
  }
}
